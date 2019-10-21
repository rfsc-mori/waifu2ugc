/*
 * MIT License
 *
 * Copyright (c) 2019 Aruraune
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0
import QtGraphicalEffects 1.12

Item {
    id: rubberband

    property bool rubberbandEnabled: visible

    property rect cropRect: Qt.rect(cropFrame.x, cropFrame.y, cropFrame.width, cropFrame.height)

    property color backgroundColor: "transparent"
    property color borderColor: "black"
    property real borderWidth: 2

    property real keySingleStep: 1
    property real keyHalfStep: keyLongStep / 2
    property real keyLongStep: 10

    property real aspectRatio: 1
    property bool preserveAspectRatio: true

    property size minSize: Qt.size(48, 48)
    property size maxSize: Qt.size(width, height)

    property real widthScale: 1
    property real heightScale: 1

    onRubberbandEnabledChanged: cropFrame.revalidateFrame()
    onAspectRatioChanged: cropFrame.updateAspectRatio()

    onMaxSizeChanged: cropFrame.needsValidation = true

    Rectangle {
        id: cropFrame

        property real containerRatio: maxSize.width / maxSize.height
        property real frameRatio: width / height

        property point initialPos: Qt.point(maxSize.width / 2 - maxFrameSize.width / 2, maxSize.height / 2 - maxFrameSize.height / 2)

        property size previousMaxSize
        property size maxFrameSize: Qt.size(preserveAspectRatio ? (aspectRatio >= containerRatio ? maxSize.width : maxSize.height * aspectRatio) : maxSize.width,
                                            preserveAspectRatio ? (aspectRatio >= containerRatio ? maxSize.width / aspectRatio : maxSize.height) : maxSize.height)

        property bool needsValidation: false

        // Handle expected positioning errors such as changing the image displayed, resizing window etc without parent's intervention
        // 0.005 adjustment was necessary to deal with floating point precision issues
        // so other rules can be enforced without needing to cater to edge cases
        // (e.g. resetting the rubberband because of <0.5 point outside resulting from keeping aspect ratio and floating point operations)
        //
        // Note: This component is a great conadidate for refactoring but releasing 1.0 sooner is more important now.
        function revalidateFrame() {
            if (rubberbandEnabled)
            {
                var rescaled = false

                if (previousMaxSize.width >= minSize.width && previousMaxSize.height >= minSize.height &&
                        Math.abs(previousMaxSize.width / previousMaxSize.height - maxSize.width / maxSize.height) < 0.005)
                {
                    var widthFactor = maxSize.width / previousMaxSize.width
                    var heightFactor = maxSize.height / previousMaxSize.height

                    if (widthFactor !== 1 && heightFactor !== 1 &&
                            width * widthFactor >= minSize.width && width * widthFactor <= maxSize.width &&
                            height * heightFactor >= minSize.height && height * heightFactor <= maxSize.height)
                    {
                        x *= widthFactor
                        y *= heightFactor
                        width *= widthFactor
                        height *= heightFactor

                        rescaled = true
                    }
                }

                if (!rescaled)
                {
                    if (width < minSize.width && height < minSize.height) resetFrame()
                    else if (x + width > maxSize.width + 0.005 || y + height > maxSize.height + 0.005) resetFrame()
                    else if (Math.abs(frameRatio - aspectRatio) > 0.005) resetFrame()
                }

                previousMaxSize.width = maxSize.width
                previousMaxSize.height = maxSize.height

                needsValidation = false
            }
        }

        function updateAspectRatio() {
            if (preserveAspectRatio)
            {
                var expandWidth = aspectRatio >= width / height ? height * aspectRatio : width
                var expandHeight = aspectRatio >= width / height ? height : width / aspectRatio

                if (x + expandWidth <= maxSize.width && y + expandHeight <= maxSize.height)
                {
                    width = expandWidth
                    height = expandHeight
                }
                else
                {
                    width = aspectRatio >= (maxSize.width - x) / (maxSize.height - y) ? (maxSize.width - x) : (maxSize.height - y) * aspectRatio
                    height = aspectRatio >= (maxSize.width - x) / (maxSize.height - y) ? (maxSize.width - x) / aspectRatio : (maxSize.height - y)
                }

                needsValidation = true
            }
        }

        function resetFrame() {
            if (rubberbandEnabled)
            {
                x = initialPos.x
                y = initialPos.y
                width = maxFrameSize.width
                height = maxFrameSize.height
            }
        }

        color: "transparent"

        border.width: borderWidth
        border.color: borderColor

        onXChanged: needsValidation = true
        onYChanged: needsValidation = true
        onWidthChanged: needsValidation = true
        onHeightChanged: needsValidation = true

        onNeedsValidationChanged: if (needsValidation) Qt.callLater(revalidateFrame)

        Keys.onUpPressed: {
            if (rubberbandEnabled && y > 0)
            {
                if (event.modifiers & Qt.ShiftModifier)
                {
                    var step = (event.modifiers & Qt.ControlModifier) ? Math.min(keyHalfStep * heightScale, y) : Math.min(keySingleStep * heightScale, y)

                    if (preserveAspectRatio)
                    {
                        var sideEffect = frameRatio > aspectRatio ? step / aspectRatio : step * aspectRatio

                        if (x + width + sideEffect <= maxSize.width)
                        {
                            height += step
                            width += sideEffect

                            y -= step
                        }
                    }
                    else
                    {
                        height += step
                        y -= step
                    }
                }
                else
                {
                    y -= (event.modifiers & Qt.ControlModifier) ? Math.min(keyLongStep * heightScale, y) : Math.min(keySingleStep * heightScale, y)
                }
            }
        }

        Keys.onLeftPressed: {
            if (rubberbandEnabled && x > 0)
            {
                if (event.modifiers & Qt.ShiftModifier)
                {
                    var step = (event.modifiers & Qt.ControlModifier) ? Math.min(keyHalfStep * widthScale, x) : Math.min(keySingleStep * widthScale, x)

                    if (preserveAspectRatio)
                    {
                        var sideEffect = frameRatio > aspectRatio ? step * aspectRatio : step / aspectRatio

                        if (y + height + sideEffect <= maxSize.height)
                        {
                            width += step
                            height += sideEffect

                            x -= step
                        }
                    }
                    else
                    {
                        width += step
                        x -= step
                    }
                }
                else
                {
                    x -= (event.modifiers & Qt.ControlModifier) ? Math.min(keyLongStep * widthScale, x) : Math.min(keySingleStep * widthScale, x)
                }
            }
        }

        Keys.onRightPressed: {
            if (rubberbandEnabled)
            {
                if (event.modifiers & Qt.ShiftModifier)
                {
                    var step = (event.modifiers & Qt.ControlModifier) ? Math.min(keyHalfStep * widthScale, width - minSize.width) : Math.min(keySingleStep * widthScale, width - minSize.width)

                    if (preserveAspectRatio)
                    {
                        var sideEffect = frameRatio > aspectRatio ? step * aspectRatio : step / aspectRatio

                        if (height - sideEffect >= minSize.height)
                        {
                            x += step

                            width -= step
                            height -= sideEffect
                        }
                    }
                    else
                    {
                        x += step
                        width -= step
                    }
                }
                else
                {
                    x += (event.modifiers & Qt.ControlModifier) ? Math.min(keyLongStep * widthScale, maxSize.width - width - x) : Math.min(keySingleStep * widthScale, maxSize.width - width - x)
                }
            }
        }

        Keys.onDownPressed: {
            if (rubberbandEnabled)
            {
                if (event.modifiers & Qt.ShiftModifier)
                {
                    var step = (event.modifiers & Qt.ControlModifier) ? Math.min(keyHalfStep * heightScale, height - minSize.height) : Math.min(keySingleStep * heightScale, height - minSize.height)

                    if (preserveAspectRatio)
                    {
                        var sideEffect = frameRatio > aspectRatio ? step / aspectRatio : step * aspectRatio

                        if (width - sideEffect >= minSize.width)
                        {
                            y += step

                            height -= step
                            width -= sideEffect
                        }
                    }
                    else
                    {
                        y += step
                        height -= step
                    }
                }
                else
                {
                    y += (event.modifiers & Qt.ControlModifier) ? Math.min(keyLongStep * heightScale, maxSize.height - height - y) : Math.min(keySingleStep * heightScale, maxSize.height - height - y)
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            drag {
                target: parent
                minimumX: 0
                minimumY: 0
                maximumX: maxSize.width - cropFrame.width
                maximumY: maxSize.height - cropFrame.height
                smoothed: true
            }

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: {
                if (rubberbandEnabled)
                {
                    parent.forceActiveFocus()

                    if (pressedButtons & Qt.RightButton)
                    {
                        cropFrame.resetFrame()
                    }
                }
            }
        }

        CropAnchor {
            attachTo: Item.TopLeft

            anchorEnabled: rubberbandEnabled
            visible: anchorEnabled

            rubberbandAspectRatio: aspectRatio
            preserveAspectRatio: rubberband.preserveAspectRatio

            minDraggableSize: minSize
            maxDraggableSize: maxSize
        }

        CropAnchor {
            attachTo: Item.TopRight

            anchorEnabled: rubberbandEnabled
            visible: anchorEnabled

            rubberbandAspectRatio: aspectRatio
            preserveAspectRatio: rubberband.preserveAspectRatio

            minDraggableSize: minSize
            maxDraggableSize: maxSize
        }

        CropAnchor {
            attachTo: Item.BottomLeft

            anchorEnabled: rubberbandEnabled
            visible: anchorEnabled

            rubberbandAspectRatio: aspectRatio
            preserveAspectRatio: rubberband.preserveAspectRatio

            minDraggableSize: minSize
            maxDraggableSize: maxSize
        }

        CropAnchor {
            attachTo: Item.BottomRight

            anchorEnabled: rubberbandEnabled
            visible: anchorEnabled

            rubberbandAspectRatio: aspectRatio
            preserveAspectRatio: rubberband.preserveAspectRatio

            minDraggableSize: minSize
            maxDraggableSize: maxSize
        }

        LinearGradient {
            id: cropFrameGradient

            anchors.fill: parent
            anchors.margins: 0

            start: Qt.point(0, 0)
            end: Qt.point(width, height)

            gradient: Gradient {
                GradientStop { position: 0.0; color: backgroundColor }
                GradientStop { position: 0.2; color: Qt.lighter(backgroundColor, 1.05) }
                GradientStop { position: 0.3; color: backgroundColor }
                GradientStop { position: 0.5; color: Qt.lighter(backgroundColor, 1.1) }
                GradientStop { position: 0.7; color: backgroundColor }
                GradientStop { position: 0.8; color: Qt.lighter(backgroundColor, 1.05) }
                GradientStop { position: 1.0; color: backgroundColor }
            }
        }
    }
}
