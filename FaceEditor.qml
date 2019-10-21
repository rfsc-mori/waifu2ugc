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
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0

import waifu2ugc 1.0

Item {
    id: editor

    property TemplateFace faceObject

    property string face
    property string faceText
    property rect faceRect
    property bool custom

    property bool faceEnabled

    property bool editing

    property int horizontalCount: 1
    property int verticalCount: 1

    property url faceImage

    property bool resizeSource
    property bool preserveAspectRatio

    property int aspectRatioIndex
    property int aspectRatioAction: aspectStrategyModel.get(aspectRatioIndex).action

    property rect fitRect
    property rect cropRect

    property size totalFaceSize: Qt.size(faceRect.width * horizontalCount, faceRect.height * verticalCount)

    property var sourceStatus
    property size sourceSize
    property bool resizingRequired: sourceSize !== totalFaceSize

    property bool isFaceRectValid: faceRect.x >= 0 && faceRect.y >= 0 && faceRect.width > 0 && faceRect.height > 0
    property bool isHorizontalCountValid: horizontalCount >= 1 && horizontalCount <= 25
    property bool isVerticalCountValid: verticalCount >= 1 && verticalCount <= 25
    property bool isFaceImageLoading: faceImage != "" && sourceStatus === Image.Loading
    property bool isFaceImageValid: faceImage != "" && sourceStatus === Image.Ready && sourceSize.width > 0 && sourceSize.height > 0
    property bool isResizingNeeded: (!resizingRequired || resizeSource)
    property bool isAspectRatioActionValid: (aspectRatioIndex == TemplateFace.FIT || aspectRatioIndex == TemplateFace.CROP)
    property bool isFitRectValid: fitRect.x >= 0 && fitRect.y >= 0 && fitRect.width > 0 && fitRect.height > 0
    property bool isResizeToFitValid: (!resizeSource || !preserveAspectRatio || aspectRatioIndex != 0 || isFitRectValid)
    property bool isCropRectValid: cropRect.x >= 0 && cropRect.y >= 0 && cropRect.width > 0 && cropRect.height > 0
    property bool isCropActionValid: (!resizeSource || !preserveAspectRatio || aspectRatioIndex != 1 || isCropRectValid)

    property bool isReady: faceEnabled &&
                           isFaceRectValid &&
                           isHorizontalCountValid &&
                           isVerticalCountValid &&
                           isFaceImageValid &&
                           isResizingNeeded &&
                           isAspectRatioActionValid &&
                           isResizeToFitValid &&
                           isCropActionValid

    function getErrors() {
        var error
        var where = faceText + ":"

        if (!isFaceRectValid)               error = where + " " + qsTr("Invalid face rect.\r\nPlease verify the x, y, width and height values or select another layout.")
        else if (!isHorizontalCountValid)   error = where + " " + qsTr("Invalid number of horizontal blocks.\r\nPlease input an amount between 1 and 25.")
        else if (!isVerticalCountValid)     error = where + " " + qsTr("Invalid number of vertical blocks.\r\nPlease input an amount between 1 and 25.")
        else if (isFaceImageLoading)        error = where + " " + qsTr("The face image is still loading.\r\nPlease wait.")
        else if (!isFaceImageValid)         error = where + " " + qsTr("Invalid face image.\r\nPlease select another image.")
        else if (!isResizingNeeded)         error = where + " " + qsTr("Resizing required.\r\nPlease mark the 'Resize' option and adjust the parameters as you like.")
        else if (!isAspectRatioActionValid) error = where + " " + qsTr("Invalid aspect ratio mismatch recovery strategy.\r\nPlease select either 'resize to fit' or 'crop'.")
        else if (!isResizeToFitValid)       error = where + " " + qsTr("Invalid 'resize to fit' settings.\r\nPlease select a valid region.")
        else if (!isCropActionValid)        error = where + " " + qsTr("Invalid 'crop' settings.\r\nPlease select a valid region.")

        return error
    }

    signal startedEditing()
    signal editingFinished()

    onEditingChanged: if (editing) startedEditing(); else editingFinished()

    implicitWidth: editorInfo.implicitWidth
    implicitHeight: editorInfo.implicitHeight

    Binding on face { value: faceObject.face }
    Binding on faceText { value: faceObject.text }

    Binding { target: faceObject; property: "faceRect"; value: faceRect }
    Binding { target: faceObject; property: "faceEnabled"; value: faceEnabled }
    Binding { target: faceObject; property: "horizontalCount"; value: horizontalCount }
    Binding { target: faceObject; property: "verticalCount"; value: verticalCount }
    Binding { target: faceObject; property: "faceImageUrl"; value: faceImage }
    Binding { target: faceObject; property: "resizeSource"; value: resizeSource }
    Binding { target: faceObject; property: "preserveAspectRatio"; value: preserveAspectRatio }
    Binding { target: faceObject; property: "aspectRatioAction"; value: aspectRatioAction }
    Binding { target: faceObject; property: "fitRect"; value: fitRect }
    Binding { target: faceObject; property: "cropRect"; value: cropRect }

    ListModel {
        id: aspectStrategyModel

        ListElement { text: qsTr("Fit"); action: TemplateFace.FIT }
        ListElement { text: qsTr("Crop"); action: TemplateFace.CROP }
    }

    GridLayout {
        id: editorInfo
        columns: 4

        anchors.fill: parent

        CheckBox {
            text: faceText
            checked: faceEnabled
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.preferredWidth: 100
            onCheckedChanged: editing = faceEnabled = checked
        }

        Label {
            text: faceRect.x + "," + faceRect.y + " - " + faceRect.width + "x" + faceRect.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
        }

        Label {
            text: horizontalCount + "x" + verticalCount
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Button {
            enabled: faceEnabled
            text: qsTr("Edit")
            onClicked: editing = true
        }

        GridLayout {
            id: editorSection
            columns: 4
            Layout.leftMargin: 20
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.columnSpan: 4

            Label {
                id: txtX
                text: qsTr("x")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                id: spinX
                value: faceRect.x
                editable: true
                to: 10240
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: faceRect.x = value
            }

            Label {
                id: txtY
                text: qsTr("y")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                id: spinY
                value: faceRect.y
                editable: true
                to: 10240
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: faceRect.y = value
            }

            Label {
                id: txtWidth
                text: qsTr("Width")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                id: spinWidth
                value: faceRect.width
                editable: true
                to: 10240
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: faceRect.width = value
            }

            Label {
                id: txtHeight
                text: qsTr("Height:")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                id: spinHeight
                value: faceRect.height
                editable: true
                to: 10240
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: faceRect.height = value
            }

            Label {
                text: qsTr("↔")
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                value: horizontalCount
                from: 1
                editable: true
                to: 25
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: horizontalCount = value
            }

            Label {
                text: qsTr("↕")
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            SpinBox {
                value: verticalCount
                from: 1
                editable: true
                to: 25
                wheelEnabled: true
                Layout.fillWidth: true
                onValueChanged: verticalCount = value
            }

            RowLayout {
                Layout.columnSpan: 4

                TextField {
                    id: fieldFaceImage
                    text: faceImage
                    placeholderText: qsTr("Please select a image or an URL...")
                    selectByMouse: true
                    Layout.leftMargin: checkAllowResizing.leftPadding
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                    onEditingFinished: {
                        var resolved = Qt.resolvedUrl(text)

                        if (resolved.toString().substring(0, 3) !== "qrc")
                        {
                            faceImage = resolved
                        }
                        else
                        {
                            faceImage = TemplateExporter.alternativeResolve(text)
                        }
                    }
                }

                Button {
                    text: qsTr("Open")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    onClicked: {
                        openFace.folder = faceImage != "" ?
                                    faceImage.toString().substring(0, faceImage.toString().lastIndexOf("/") + 1) :
                                    openFace.shortcuts.home

                        openFace.open()
                    }
                }

                FileDialog {
                    id: openFace
                    title: qsTr("Please select an image")
                    nameFilters: [qsTr("Image Files") + "(" + imageExtensions + ")", qsTr("All files") + "(*)"]
                    onAccepted: faceImage = fileUrl
                }
            }

            CheckBox {
                id: checkAllowResizing
                checked: resizeSource
                text: qsTr("Resize")
                Layout.columnSpan: 2
                onCheckedChanged: resizeSource = checked;
            }

            RowLayout {
                id: aspectSection
                Layout.columnSpan: 4

                CheckBox {
                    id: checkPreserveAspect
                    checked: preserveAspectRatio
                    text: qsTr("Preserve aspect ratio")
                    onCheckedChanged: preserveAspectRatio = checked
                }

                ComboBox {
                    id: comboAspectRatio
                    model: aspectStrategyModel
                    currentIndex: aspectRatioIndex
                    textRole: "text"
                    onCurrentIndexChanged: aspectRatioIndex = currentIndex
                }

                states: [
                    State {
                        name: "resize to fit"
                        when: resizeSource && preserveAspectRatio && aspectRatioIndex == 0
                        PropertyChanges { target: checkPreserveAspect; visible: true }
                        PropertyChanges { target: comboAspectRatio; visible: true }
                    },
                    State {
                        name: "resize and crop"
                        when: resizeSource && preserveAspectRatio && aspectRatioIndex == 1
                        PropertyChanges { target: checkPreserveAspect; visible: true }
                        PropertyChanges { target: comboAspectRatio; visible: true }
                    },
                    State {
                        name: "resize"
                        when: resizeSource
                        PropertyChanges { target: checkPreserveAspect; visible: true }
                        PropertyChanges { target: comboAspectRatio; visible: false }
                    },
                    State {
                        name: "use source"
                        when: !resizeSource
                        PropertyChanges { target: checkPreserveAspect; visible: false }
                        PropertyChanges { target: comboAspectRatio; visible: false }
                    }
                ]
            }

            states: [
                State {
                    name: "preset"
                    when: !custom
                    PropertyChanges { target: txtX; visible: false }
                    PropertyChanges { target: spinX; visible: false }
                    PropertyChanges { target: txtY; visible: false }
                    PropertyChanges { target: spinY; visible: false }
                    PropertyChanges { target: txtWidth; visible: false }
                    PropertyChanges { target: spinWidth; visible: false }
                    PropertyChanges { target: txtHeight; visible: false }
                    PropertyChanges { target: spinHeight; visible: false }
                },
                State {
                    name: "custom"
                    when: custom
                    PropertyChanges { target: txtX; visible: true }
                    PropertyChanges { target: spinX; visible: true }
                    PropertyChanges { target: txtY; visible: true }
                    PropertyChanges { target: spinY; visible: true }
                    PropertyChanges { target: txtWidth; visible: true }
                    PropertyChanges { target: spinWidth; visible: true }
                    PropertyChanges { target: txtHeight; visible: true }
                    PropertyChanges { target: spinHeight; visible: true }
                }
            ]
        }
    }

    states: [
        State {
            name: "editing"
            when: editing
            PropertyChanges { target: editorSection; Layout.preferredHeight: editorSection.implicitHeight }
            PropertyChanges { target: editorSection; visible: true }
            PropertyChanges { target: editorSection; clip: false }
        },
        State {
            name: "idle"
            when: !editing
            PropertyChanges { target: editorSection; clip: true }
            PropertyChanges { target: editorSection; Layout.preferredHeight: 0 }
            PropertyChanges { target: editorSection; visible: false }
        }
    ]

    transitions: [
        Transition {
            from: "idle"; to: "editing"
            SequentialAnimation {
                PropertyAction { property: "visible" }
                NumberAnimation { property: "Layout.preferredHeight"; duration: 150 }
                PropertyAction { property: "clip" }
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
##^##*/
