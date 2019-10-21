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

import waifu2ugc 1.0

Item {
    id: view

    property FaceEditor editor

    property url faceImage: editor.faceImage
    property size sourceSize: sourceView.sourceSize
    property var faceStatus: sourceView.status

    property bool resizeSource: editor.resizeSource
    property bool preserveAspectRatio: editor.preserveAspectRatio
    property int aspectRatioAction: editor.aspectRatioAction

    property rect faceRect: editor.faceRect
    property int horizontalCount: editor.horizontalCount
    property int verticalCount: editor.verticalCount

    property size totalFaceSize: editor.totalFaceSize
    property bool resizingRequired: editor.resizingRequired

    property real totalFaceRatio: totalFaceSize.width / totalFaceSize.height

    property rect faceFitRect: resizeToFitView.scaledFitRect
    property rect faceCropRect: cropView.scaledCropRect

    property rect totalFitRect: resizeToFitFrame.totalFitRect
    property rect totalCropRect: cropFrame.totalCropRect

    function gcd(numerator, denominator) {
        return (isNaN(denominator) || Math.round(denominator) == 0) ? Math.round(numerator) : gcd(Math.round(denominator), Math.round(numerator % denominator))
    }

    function aspectRatioStr(size) {
        var divisor = gcd(Math.round(size.width), Math.round(size.height))
        return Math.round(size.width / divisor) + " : " + Math.round(size.height / divisor)
    }

    implicitHeight: mainFrame.implicitHeight

    Binding { target: editor; property: "sourceSize"; value: sourceSize }
    Binding { target: editor; property: "sourceStatus"; value: faceStatus }
    Binding { target: editor; property: "fitRect"; value: faceFitRect }
    Binding { target: editor; property: "cropRect"; value: faceCropRect }

    ColumnLayout {
        id: mainFrame
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Image {
                id: backgroundImage
                asynchronous: true
                source: "images/background.png"
                fillMode: Image.Tile
                anchors.fill: parent
            }

            Rectangle {
                radius: 25
                anchors.centerIn: parent
                width: loadingSource.width * 1.2
                height: loadingSource.height * 1.2
                visible: loadingSource.running

                BusyIndicator {
                    id: loadingSource
                    anchors.centerIn: parent
                    running: sourceView.status === Image.Loading
                }
            }

            Item {
                id: viewFrame
                anchors.fill: parent
                anchors.margins: 10

                Rectangle {
                    id: sourceFrame
                    color: "transparent"
                    border.color: "black"
                    border.width: 2
                    width: totalFaceRatio >= (parent.width / parent.height) ? parent.width : parent.height * totalFaceRatio
                    height: totalFaceRatio >= (parent.width / parent.height) ? parent.width / totalFaceRatio : parent.height
                    anchors.centerIn: parent

                    Image {
                        id: sourceView
                        asynchronous: true
                        source: faceImage ? faceImage : ""
                        fillMode: Image.PreserveAspectFit
                        anchors.fill: parent
                        anchors.margins: sourceFrame.border.width

                        onStatusChanged: {
                            if (status == Image.Error)
                            {
                                faceImageError.message = qsTr("Failed to load image from:") + "\r\n" + faceImage
                                faceImageError.open()
                            }
                        }

                        FaceGrid {
                            horizontalCount: view.horizontalCount
                            verticalCount: view.verticalCount
                            faceSize: Qt.size(faceRect.width, faceRect.height)
                            opacity: 0.5
                            anchors.fill: parent
                        }

                        Popup {
                            id: faceImageError

                            property string message

                            modal: true
                            focus: true
                            anchors.centerIn: parent

                            contentItem: Text {
                                text: faceImageError.message
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }

                Rectangle {
                    id: resizeFrame
                    color: "transparent"
                    border.color: "black"
                    border.width: 2
                    width: totalFaceRatio >= (parent.width / parent.height) ? parent.width : parent.height * totalFaceRatio
                    height: totalFaceRatio >= (parent.width / parent.height) ? parent.width / totalFaceRatio : parent.height
                    anchors.centerIn: parent

                    Image {
                        id: resizeView
                        asynchronous: true
                        source: sourceView.source
                        fillMode: Image.Stretch
                        anchors.fill: parent
                        anchors.margins: resizeFrame.border.width

                        FaceGrid {
                            horizontalCount: view.horizontalCount
                            verticalCount: view.verticalCount
                            faceSize: Qt.size(faceRect.width, faceRect.height)
                            opacity: 0.5
                            anchors.fill: parent
                        }
                    }
                }

                Rectangle {
                    id: resizeToFitFrame

                    property real totalFitWidthScale: totalFaceSize.width / resizeToFitView.fitRect.width
                    property real totalFitHeightScale: totalFaceSize.height / resizeToFitView.fitRect.height

                    property rect totalFitRect: Qt.rect(resizeToFitView.fitRect.x * totalFitWidthScale,
                                                        resizeToFitView.fitRect.y * totalFitHeightScale,
                                                        resizeToFitView.fitRect.width * totalFitWidthScale,
                                                        resizeToFitView.fitRect.height * totalFitHeightScale)

                    color: "transparent"
                    border.color: "black"
                    border.width: 2
                    width: border.width * 2 + (totalFaceRatio >= (parent.width / parent.height) ? parent.width : parent.height * totalFaceRatio)
                    height: border.width * 2 + (totalFaceRatio >= (parent.width / parent.height) ? parent.width / totalFaceRatio : parent.height)
                    anchors.centerIn: parent

                    LinearGradient {
                        id: resizeToFitGradient

                        property color backgroundColor: "#61FCC6E2"

                        anchors.fill: parent
                        anchors.margins: resizeToFitFrame.border.width

                        start: Qt.point(0, 0)
                        end: Qt.point(width, height)

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: resizeToFitGradient.backgroundColor }
                            GradientStop { position: 0.2; color: Qt.lighter(resizeToFitGradient.backgroundColor, 1.05) }
                            GradientStop { position: 0.3; color: resizeToFitGradient.backgroundColor }
                            GradientStop { position: 0.5; color: Qt.lighter(resizeToFitGradient.backgroundColor, 1.1) }
                            GradientStop { position: 0.7; color: resizeToFitGradient.backgroundColor }
                            GradientStop { position: 0.8; color: Qt.lighter(resizeToFitGradient.backgroundColor, 1.05) }
                            GradientStop { position: 1.0; color: resizeToFitGradient.backgroundColor }
                        }

                        Keys.onUpPressed: resizeToFitView.y -= Math.min(1 * resizeToFitView.heightScale, resizeToFitView.y)
                        Keys.onLeftPressed: resizeToFitView.x -= Math.min(1 * resizeToFitView.widthScale, resizeToFitView.x)
                        Keys.onRightPressed: resizeToFitView.x += Math.min(1 * resizeToFitView.widthScale, resizeToFitView.width - resizeToFitView.paintedWidth - resizeToFitView.x)
                        Keys.onDownPressed: resizeToFitView.y += Math.min(1 * resizeToFitView.heightScale, resizeToFitView.height - resizeToFitView.paintedHeight - resizeToFitView.y)

                        MouseArea {
                            id: resizeToFitMouse
                            anchors.fill: parent

                            drag {
                                target: resizeToFitView
                                minimumX: 0
                                minimumY: 0
                                maximumX: resizeToFitView.width - resizeToFitView.paintedWidth
                                maximumY: resizeToFitView.height - resizeToFitView.paintedHeight
                            }

                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onPressed: {
                                parent.forceActiveFocus()

                                if (pressedButtons & Qt.RightButton)
                                {
                                    resizeToFitView.x = resizeToFitView.width / 2 - resizeToFitView.paintedWidth / 2
                                    resizeToFitView.y = resizeToFitView.height / 2 - resizeToFitView.paintedHeight / 2
                                }
                            }
                        }

                        Image {
                            id: resizeToFitView

                            property bool beingDragged: resizeToFitMouse.drag.active

                            property rect fitRect
                            property rect scaledFitRect: Qt.rect(fitRect.x / widthScale, fitRect.y / heightScale, fitRect.width / widthScale, fitRect.height / heightScale)

                            property real widthScale: paintedWidth / sourceSize.width
                            property real heightScale: paintedHeight / sourceSize.height

                            function reset() {
                                x = width / 2 - paintedWidth / 2
                                y = height / 2 - paintedHeight / 2
                                fitRect = Qt.rect(x, y, width, height)
                            }

                            width: parent.width
                            height: parent.height

                            asynchronous: true
                            source: sourceView.source
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignLeft
                            verticalAlignment: Image.AlignTop

                            onStatusChanged: if (status == Image.Ready) reset()

                            onXChanged: fitRect = Qt.rect(x, y, width, height)
                            onYChanged: fitRect = Qt.rect(x, y, width, height)

                            onWidthChanged: { x = fitRect.x * width / fitRect.width; fitRect = Qt.rect(x, y, width, height) }
                            onHeightChanged: { y = fitRect.y * height / fitRect.height; fitRect = Qt.rect(x, y, width, height) }

                            Connections {
                                target: resizeToFitView.parent
                                onWidthChanged: resizeToFitView.reset()
                                onHeightChanged: resizeToFitView.reset()
                            }
                        }

                        FaceGrid {
                            horizontalCount: view.horizontalCount
                            verticalCount: view.verticalCount
                            faceSize: Qt.size(faceRect.width, faceRect.height)
                            opacity: 0.5
                            anchors.fill: parent
                        }
                    }
                }

                Item {
                    id: cropFrame
                    anchors.fill: parent

                    property real totalCropWidthScale: totalFaceSize.width / cropView.cropRect.width
                    property real totalCropHeightScale: totalFaceSize.height / cropView.cropRect.height

                    property rect totalCropRect: Qt.rect(0, 0, cropView.cropRect.width * totalCropWidthScale, cropView.cropRect.height * totalCropHeightScale)

                    Image {
                        id: cropView

                        property rect cropRect: rubberband.cropRect
                        property rect scaledCropRect: Qt.rect(cropRect.x / widthScale, cropRect.y / heightScale, cropRect.width / widthScale, cropRect.height / heightScale)

                        property real widthScale: paintedWidth / sourceSize.width
                        property real heightScale: paintedHeight / sourceSize.height

                        asynchronous: true
                        source: sourceView.source
                        fillMode: Image.PreserveAspectFit
                        anchors.fill: parent

                        Item {
                            width: cropView.paintedWidth
                            height: cropView.paintedHeight

                            anchors.centerIn: parent

                            Rectangle {
                                color: "transparent"
                                anchors.fill: parent

                                border {
                                    color: "black"
                                    width: 2
                                }

                                CropRubberBand {
                                    id: rubberband
                                    aspectRatio: totalFaceRatio
                                    widthScale: cropView.widthScale
                                    heightScale: cropView.heightScale
                                    anchors.fill: parent

                                    FaceGrid {
                                        horizontalCount: view.horizontalCount
                                        verticalCount: view.verticalCount
                                        faceSize: Qt.size(faceRect.width, faceRect.height)
                                        opacity: 0.75
                                        lineWidth: 0.5
                                        x: cropView.cropRect.x
                                        y: cropView.cropRect.y
                                        width: cropView.cropRect.width
                                        height: cropView.cropRect.height
                                    }
                                }
                            }
                        }
                    }
                }
            }

            OpacityMask {
                id: seeThrough
                anchors.fill: parent
                source: backgroundImage
                maskSource: seeThroughMask
                opacity: 0.6
                invert: true

                Item {
                    id: seeThroughMask
                    anchors.fill: parent
                    visible: false

                    Rectangle {
                        x: viewFrame.anchors.leftMargin + cropView.width / 2 - cropView.paintedWidth / 2 + cropView.cropRect.x
                        y: viewFrame.anchors.rightMargin + cropView.height / 2 - cropView.paintedHeight / 2 + cropView.cropRect.y
                        width: cropView.cropRect.width
                        height: cropView.cropRect.height
                    }
                }
            }
        }

        Label {
            id: sourceInfo
            text: qsTr("Source:") + " " + sourceSize.width + "x" + sourceSize.height + " (" + aspectRatioStr(sourceSize) + ")"
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
        }

        Label {
            id: totalSizeInfo
            text: qsTr("Required:") + " " + totalFaceSize.width + "x" + totalFaceSize.height + " (" + aspectRatioStr(totalFaceSize) + ")"
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter

            Binding on color { when: resizingRequired; value: "red" }
        }

        Label {
            id: resizeInfo
            text: qsTr("Resized:") + " " + totalFaceSize.width + "x" + totalFaceSize.height + " (" + aspectRatioStr(totalFaceSize) + ")"
            color: "red"
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
        }

        Label {
            id: resizeToFitInfo
            text: qsTr("Resize to fit:") + " " +
                  Math.round(faceFitRect.x) + "," + Math.round(faceFitRect.y) + " - " + Math.round(faceFitRect.width) + "x" + Math.round(faceFitRect.height) + " " + qsTr("→") + " " +
                  Math.round(totalFitRect.x) + "," + Math.round(totalFitRect.y) + " - " + Math.round(totalFitRect.width) + "x" + Math.round(totalFitRect.height) + " (" + aspectRatioStr(faceFitRect) + ")"
            color: "red"
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
        }

        Label {
            id: cropInfo
            text: qsTr("Crop:") + " " +
                  Math.round(faceCropRect.x) + "," + Math.round(faceCropRect.y) + " - " + Math.round(faceCropRect.width) + "x" + Math.round(faceCropRect.height) + " " + qsTr("→") + " " +
                  Math.round(totalCropRect.width) + "x" + Math.round(totalCropRect.height) + " (" + aspectRatioStr(faceCropRect) + ")"
            color: "red"
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
        }

        Text { id: spacer }
    }

    states: [
        State {
            name: "resize and crop"
            when: resizeSource && preserveAspectRatio && aspectRatioAction === TemplateFace.CROP && faceStatus == Image.Ready
            PropertyChanges { target: backgroundImage; visible: false }
            PropertyChanges { target: seeThrough; visible: true }
            PropertyChanges { target: sourceFrame; visible: false }
            PropertyChanges { target: resizeFrame; visible: false }
            PropertyChanges { target: resizeToFitFrame; visible: false }
            PropertyChanges { target: cropFrame; visible: true }
            PropertyChanges { target: sourceInfo; visible: true }
            PropertyChanges { target: totalSizeInfo; visible: true }
            PropertyChanges { target: resizeInfo; visible: false }
            PropertyChanges { target: resizeToFitInfo; visible: false }
            PropertyChanges { target: cropInfo; visible: true }
            PropertyChanges { target: spacer; visible: true }
        },
        State {
            name: "resize to fit"
            when: resizeSource && preserveAspectRatio && aspectRatioAction === TemplateFace.FIT && faceStatus == Image.Ready
            PropertyChanges { target: backgroundImage; visible: true }
            PropertyChanges { target: seeThrough; visible: false }
            PropertyChanges { target: sourceFrame; visible: false }
            PropertyChanges { target: resizeFrame; visible: false }
            PropertyChanges { target: resizeToFitFrame; visible: true }
            PropertyChanges { target: cropFrame; visible: false }
            PropertyChanges { target: sourceInfo; visible: true }
            PropertyChanges { target: totalSizeInfo; visible: true }
            PropertyChanges { target: resizeInfo; visible: false }
            PropertyChanges { target: resizeToFitInfo; visible: true }
            PropertyChanges { target: cropInfo; visible: false }
            PropertyChanges { target: spacer; visible: true }
        },
        State {
            name: "resize"
            when: resizeSource && faceStatus == Image.Ready
            PropertyChanges { target: backgroundImage; visible: true }
            PropertyChanges { target: seeThrough; visible: false }
            PropertyChanges { target: sourceFrame; visible: false }
            PropertyChanges { target: resizeFrame; visible: true }
            PropertyChanges { target: resizeToFitFrame; visible: false }
            PropertyChanges { target: cropFrame; visible: false }
            PropertyChanges { target: sourceInfo; visible: true }
            PropertyChanges { target: totalSizeInfo; visible: true }
            PropertyChanges { target: resizeInfo; visible: true }
            PropertyChanges { target: resizeToFitInfo; visible: false }
            PropertyChanges { target: cropInfo; visible: false }
            PropertyChanges { target: spacer; visible: true }
        },
        State {
            name: "use source"
            when: !resizeSource && faceStatus == Image.Ready
            PropertyChanges { target: backgroundImage; visible: true }
            PropertyChanges { target: seeThrough; visible: false }
            PropertyChanges { target: sourceFrame; visible: true }
            PropertyChanges { target: resizeFrame; visible: false }
            PropertyChanges { target: resizeToFitFrame; visible: false }
            PropertyChanges { target: cropFrame; visible: false }
            PropertyChanges { target: sourceInfo; visible: true }
            PropertyChanges { target: totalSizeInfo; visible: true }
            PropertyChanges { target: resizeInfo; visible: false }
            PropertyChanges { target: resizeToFitInfo; visible: false }
            PropertyChanges { target: cropInfo; visible: false }
            PropertyChanges { target: spacer; visible: true }
        },
        State {
            name: "idle"
            when: faceStatus != Image.Ready
            PropertyChanges { target: backgroundImage; visible: true }
            PropertyChanges { target: seeThrough; visible: false }
            PropertyChanges { target: sourceFrame; visible: false }
            PropertyChanges { target: resizeFrame; visible: false }
            PropertyChanges { target: resizeToFitFrame; visible: false }
            PropertyChanges { target: cropFrame; visible: false }
            PropertyChanges { target: sourceInfo; visible: false }
            PropertyChanges { target: totalSizeInfo; visible: false }
            PropertyChanges { target: resizeInfo; visible: false }
            PropertyChanges { target: resizeToFitInfo; visible: false }
            PropertyChanges { target: cropInfo; visible: false }
            PropertyChanges { target: spacer; visible: false }
        }
    ]
}
