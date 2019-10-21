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

Item {
    property Item draggable: parent

    property int attachTo
    property bool anchorEnabled: true

    property real rubberbandAspectRatio
    property bool preserveAspectRatio

    property size minDraggableSize
    property size maxDraggableSize

    property color anchorColor: "transparent"
    property color borderColor: "black"
    property real borderWidth: 0.5

    property real xPrecision: 1/width
    property real yPrecision: 1/height

    width: 25
    height: width

    anchors.top: attachTo == Item.TopLeft || attachTo == Item.TopRight ? draggable.top : undefined
    anchors.right: attachTo == Item.TopRight || attachTo == Item.BottomRight ? draggable.right : undefined
    anchors.bottom: attachTo == Item.BottomLeft || attachTo == Item.BottomRight ? draggable.bottom : undefined
    anchors.left: attachTo == Item.TopLeft || attachTo == Item.BottomLeft ? draggable.left : undefined

    Rectangle {
        color: anchorColor

        border {
            color: borderColor
            width: borderWidth
        }

        anchors.fill: parent

        MouseArea {
            anchors.fill: parent

            drag {
                target: parent
                axis: Drag.XAndYAxis
                smoothed: true
            }

            property real minX: attachTo == Item.TopLeft || attachTo == Item.BottomLeft ?
                                    (draggable.x + draggable.width - maxDraggableSize.width > 0 ? draggable.x + draggable.width - maxDraggableSize.width : 0) :
                                    0

            property real minY: attachTo == Item.TopLeft || attachTo == Item.TopRight ?
                                    (draggable.y + draggable.height - maxDraggableSize.height > 0 ? draggable.y + draggable.height - maxDraggableSize.height : 0) :
                                    0

            property real maxX: attachTo == Item.TopLeft || attachTo == Item.BottomLeft ?
                                    draggable.x + draggable.width - minDraggableSize.width :
                                    draggable.parent.width - draggable.width

            property real maxY: attachTo == Item.TopLeft || attachTo == Item.TopRight ?
                                    draggable.y + draggable.height - minDraggableSize.height :
                                    draggable.parent.height - draggable.height

            property int modX: attachTo == Item.TopLeft || attachTo == Item.BottomLeft ? -1 : 1
            property int modY: attachTo == Item.TopLeft || attachTo == Item.TopRight ? -1 : 1

            onPositionChanged: {
                if (drag.active && anchorEnabled)
                {
                    var deltaX
                    var deltaY

                    if (attachTo == Item.TopLeft || attachTo == Item.BottomLeft)
                    {
                        deltaX = draggable.x + mouseX < minX ? minX - draggable.x : mouseX
                    }
                    else
                    {
                        deltaX = draggable.x + mouseX > maxX ? maxX - draggable.x : mouseX
                    }

                    if (attachTo == Item.TopLeft || attachTo == Item.TopRight)
                    {
                        deltaY = draggable.y + mouseY < minY ? minY - draggable.y : mouseY
                    }
                    else
                    {
                        deltaY = draggable.y + mouseY > maxY ? maxY - draggable.y : mouseY
                    }

                    var targetWidth = Math.max(minDraggableSize.width, Math.min(draggable.width + (deltaX * xPrecision * modX), maxDraggableSize.width))
                    var targetHeight = Math.max(minDraggableSize.height, Math.min(draggable.height + (deltaY * yPrecision * modY), maxDraggableSize.height))

                    var ignore = false

                    if (preserveAspectRatio)
                    {
                        var adjustedWidth = rubberbandAspectRatio > targetWidth / targetHeight ? targetWidth : targetHeight * rubberbandAspectRatio
                        var adjustedHeight = rubberbandAspectRatio > targetWidth / targetHeight ? targetWidth / rubberbandAspectRatio : targetHeight

                        if (adjustedWidth < minDraggableSize.width || adjustedWidth > maxDraggableSize.width ||
                                adjustedHeight < minDraggableSize.height || adjustedHeight > maxDraggableSize.height)
                        {
                            ignore = true
                        }

                        var newDeltaX = draggable.width - adjustedWidth
                        var newDeltaY = draggable.height - adjustedHeight

                        if (attachTo == Item.TopLeft || attachTo == Item.BottomLeft)
                        {
                            if (draggable.x - (-newDeltaX) < minX)
                            {
                                ignore = true
                            }
                        }
                        else
                        {
                            if (draggable.x + (-newDeltaX) > maxX)
                            {
                                ignore = true
                            }
                        }

                        if (attachTo == Item.TopLeft || attachTo == Item.TopRight)
                        {
                            if (draggable.y - (-newDeltaY) < minY)
                            {
                                ignore = true
                            }
                        }
                        else
                        {
                            if (draggable.y + (-newDeltaY) > maxY)
                            {
                                ignore = true
                            }
                        }
                    }
                    else
                    {
                        newDeltaX = draggable.width - targetWidth
                        newDeltaY = draggable.height - targetHeight
                    }

                    if (!ignore)
                    {
                        draggable.width += (-newDeltaX)
                        draggable.height += (-newDeltaY)

                        if (attachTo == Item.TopLeft || attachTo == Item.BottomLeft)
                        {
                            draggable.x += newDeltaX
                        }

                        if (attachTo == Item.TopLeft || attachTo == Item.TopRight)
                        {
                            draggable.y += newDeltaY
                        }
                    }
                }
            }
        }
    }
}
