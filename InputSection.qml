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
import QtQml.StateMachine 1.0 as DSM

import waifu2ugc 1.0

Item
{
    property FaceEditor currentEditor

    property int currentLayoutIndex: comboLayout.currentIndex

    property var defaultLayout: templateLayoutModel.get(0)
    property var currentLayout: templateLayoutModel.get(currentLayoutIndex)

    property bool atLeastOneEnabled: frontEditor.faceEnabled  || topEditor.faceEnabled  ||
                                     rightEditor.faceEnabled  || backEditor.faceEnabled ||
                                     bottomEditor.faceEnabled || leftEditor.faceEnabled

    property bool editorsReady: (!frontEditor.faceEnabled  || frontEditor.isReady)  &&
                                (!topEditor.faceEnabled    || topEditor.isReady)    &&
                                (!rightEditor.faceEnabled  || rightEditor.isReady)  &&
                                (!backEditor.faceEnabled   || backEditor.isReady)   &&
                                (!bottomEditor.faceEnabled || bottomEditor.isReady) &&
                                (!leftEditor.faceEnabled   || leftEditor.isReady)

    // TODO: Ver a coisa do template
    property bool isTemplateLoading: template.source != "" && template.status === Image.Loading
    property bool isTemplateValid: template.source != "" && template.status === Image.Ready && template.sourceSize.width > 0 && template.sourceSize.height > 0

    property bool ready: atLeastOneEnabled && editorsReady && !isTemplateLoading && isTemplateValid

    property var editors: {
        "front": frontEditor,
        "top": topEditor,
        "right": rightEditor,
        "back": backEditor,
        "bottom": bottomEditor,
        "left": leftEditor
    }

    property string imageExtensions: TemplateExporter.supportedImageTypes()

    function getErrors() {
        var errors = []
        var where = qsTr("Template:")

        if (!atLeastOneEnabled)      errors.push(where + " " + qsTr("Please enable at least one face."))
        else if (isTemplateLoading)  errors.push(where + " " + qsTr("The template image is still loading.\r\nPlease wait."))
        else if (!isTemplateValid)   errors.push(where + " " + qsTr("Invalid template image.\r\nPlease select another image."))

        if (frontEditor.faceEnabled  && !frontEditor.isReady)  errors.push(frontEditor.getErrors())
        if (topEditor.faceEnabled    && !topEditor.isReady)    errors.push(topEditor.getErrors())
        if (rightEditor.faceEnabled  && !rightEditor.isReady)  errors.push(rightEditor.getErrors())
        if (backEditor.faceEnabled   && !backEditor.isReady)   errors.push(backEditor.getErrors())
        if (bottomEditor.faceEnabled && !bottomEditor.isReady) errors.push(bottomEditor.getErrors())
        if (leftEditor.faceEnabled   && !leftEditor.isReady)   errors.push(leftEditor.getErrors())

        return errors;
    }

    implicitWidth: mainFrame.implicitWidth
    implicitHeight: mainFrame.implicitHeight

    Binding { target: TemplateExporter; property: "templateUrl"; value: template.source }

    Binding { target: frontEditor; property: "faceObject"; value: TemplateExporter.frontFace }
    Binding { target: topEditor; property: "faceObject"; value: TemplateExporter.topFace }
    Binding { target: rightEditor; property: "faceObject"; value: TemplateExporter.rightFace }
    Binding { target: backEditor; property: "faceObject"; value: TemplateExporter.backFace }
    Binding { target: bottomEditor; property: "faceObject"; value: TemplateExporter.bottomFace }
    Binding { target: leftEditor; property: "faceObject"; value: TemplateExporter.leftFace }

    TemplateLayoutModel {
        id: templateLayoutModel
    }

    ColumnLayout {
        id: mainFrame

        GridLayout {
            id: templateSection
            columns: 4

            GridLayout {
                Layout.columnSpan: templateSection.columns
                Layout.minimumHeight: 300
                Layout.maximumHeight: 300
                Layout.preferredHeight: 300

                Image {
                    id: template

                    property url customImage
                    property url image: currentLayout.image !== undefined ? currentLayout.image : defaultLayout.image

                    property real widthScale: paintedWidth / sourceSize.width
                    property real heightScale: paintedHeight / sourceSize.height
                    property real preferredScale: widthScale

                    asynchronous: true
                    mipmap: true

                    source: customImage != "" ? customImage : image
                    fillMode: Image.PreserveAspectFit

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onStatusChanged: {
                        if (status == Image.Error && customImage != "")
                        {
                            templateError.message = qsTr("Failed to load:") + "\r\n" + customImage
                            customImage = ""

                            templateError.open()
                        }
                    }

                    Popup {
                        id: templateError

                        property string message

                        modal: true
                        focus: true
                        anchors.centerIn: parent

                        contentItem: Text {
                            text: templateError.message
                            wrapMode: Text.Wrap
                        }
                    }

                    Rectangle {
                        radius: 25
                        anchors.centerIn: parent
                        width: loadingTemplate.width * 1.2
                        height: loadingTemplate.height * 1.2
                        visible: loadingTemplate.running

                        BusyIndicator {
                            id: loadingTemplate
                            anchors.centerIn: parent
                            running: template.status === Image.Loading
                        }
                    }

                    Item {
                        id: thumbnailsSection

                        clip: true

                        width: template.sourceSize.width
                        height: template.sourceSize.height

                        visible: template.status != Image.Loading

                        transform: [
                            Scale { xScale: template.widthScale; yScale: template.heightScale },
                            Translate { x: template.width / 2 - template.paintedWidth / 2; y: template.height / 2 - template.paintedHeight / 2 }
                        ]

                        FaceThumbnail {
                            baseColor: "#7D448AF6"
                            enabled: frontEditor.faceEnabled
                            current: frontEditor.editing
                            ready: frontEditor.isReady
                            faceRect: frontEditor.faceRect
                            faceImage: frontEditor.faceImage
                            faceText: frontEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: frontEditor.editing = true
                        }

                        FaceThumbnail {
                            baseColor: "#7DF6AE41"
                            enabled: topEditor.faceEnabled
                            current: topEditor.editing
                            ready: frontEditor.isReady
                            faceRect: topEditor.faceRect
                            faceImage: topEditor.faceImage
                            faceText: topEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: topEditor.editing = true
                        }

                        FaceThumbnail {
                            baseColor: "#7D7FB220"
                            enabled: rightEditor.faceEnabled
                            current: rightEditor.editing
                            ready: frontEditor.isReady
                            faceRect: rightEditor.faceRect
                            faceImage: rightEditor.faceImage
                            faceText: rightEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: rightEditor.editing = true
                        }

                        FaceThumbnail {
                            baseColor: "#7DC957EA"
                            enabled: backEditor.faceEnabled
                            current: backEditor.editing
                            ready: frontEditor.isReady
                            faceRect: backEditor.faceRect
                            faceImage: backEditor.faceImage
                            faceText: backEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: backEditor.editing = true
                        }

                        FaceThumbnail {
                            baseColor: "#7DFF7F7F"
                            enabled: bottomEditor.faceEnabled
                            current: bottomEditor.editing
                            ready: frontEditor.isReady
                            faceRect: bottomEditor.faceRect
                            faceImage: bottomEditor.faceImage
                            faceText: bottomEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: bottomEditor.editing = true
                        }

                        FaceThumbnail {
                            baseColor: "#7D21C596"
                            enabled: leftEditor.faceEnabled
                            current: leftEditor.editing
                            ready: frontEditor.isReady
                            faceRect: leftEditor.faceRect
                            faceImage: leftEditor.faceImage
                            faceText: leftEditor.faceText
                            borderWidth: 3 / template.preferredScale
                            textMarginFactor: 0.5 * template.preferredScale
                            onFaceClicked: leftEditor.editing = true
                        }
                    }
                }
            }

            Label {
                text: qsTr("Layout:")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: comboLayout
                model: templateLayoutModel
                textRole: "text"
            }

            Button {
                text: qsTr("New Template")

                onClicked: {
                    openTemplate.folder = template.customImage != "" ?
                                template.customImage.toString().substring(0, template.customImage.toString().lastIndexOf("/") + 1) :
                                openTemplate.shortcuts.home

                    openTemplate.open()
                }
            }

            Button {
                text: qsTr("Reset")
                enabled: template.customImage != ""
                onClicked: template.customImage = ""
            }

            FileDialog {
                id: openTemplate
                title: qsTr("Please select a template")
                nameFilters: [qsTr("Image Files") + "(" + imageExtensions + ")", qsTr("All files") + "(*)"]
                onAccepted: template.customImage = fileUrl
            }

            ColumnLayout {
                id: facesSection

                function parseRect(text) {
                    if (text)
                    {
                        var numbers = text.split(",")
                        return Qt.rect(numbers[0], numbers[1], numbers[2], numbers[3])
                    }
                    else
                    {
                        return undefined
                    }
                }

                function layoutRect(index, face) {
                    var layout = templateLayoutModel.get(index)

                    if (layout[face])
                    {
                        return parseRect(layout[face])
                    }
                }

                Layout.columnSpan: templateSection.columns

                FaceEditor {
                    id: frontEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: frontEditor.layoutRect !== undefined; value: frontEditor.layoutRect }
                }

                FaceEditor {
                    id: topEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: topEditor.layoutRect !== undefined; value: topEditor.layoutRect }
                }

                FaceEditor {
                    id: rightEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: rightEditor.layoutRect !== undefined; value: rightEditor.layoutRect }
                }

                FaceEditor {
                    id: backEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: backEditor.layoutRect !== undefined; value: backEditor.layoutRect }
                }

                FaceEditor {
                    id: bottomEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: bottomEditor.layoutRect !== undefined; value: bottomEditor.layoutRect }
                }

                FaceEditor {
                    id: leftEditor

                    property var layoutRect: facesSection.layoutRect(currentLayoutIndex, face)

                    custom: currentLayout.custom
                    Layout.fillWidth: true

                    Binding on faceRect { when: leftEditor.layoutRect !== undefined; value: leftEditor.layoutRect }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    DSM.StateMachine {
        initialState: editingFaces
        running: true

        DSM.State {
            id: editingFaces
            initialState: editingNone

            DSM.SignalTransition { targetState: editingFront; signal: frontEditor.startedEditing }
            DSM.SignalTransition { targetState: editingTop; signal: topEditor.startedEditing }
            DSM.SignalTransition { targetState: editingRight; signal: rightEditor.startedEditing }
            DSM.SignalTransition { targetState: editingBack; signal: backEditor.startedEditing }
            DSM.SignalTransition { targetState: editingBottom; signal: bottomEditor.startedEditing }
            DSM.SignalTransition { targetState: editingLeft; signal: leftEditor.startedEditing }

            DSM.State {
                id: editingNone

                onEntered: {
                    frontEditor.editing = false
                    topEditor.editing = false
                    rightEditor.editing = false
                    backEditor.editing = false
                    bottomEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = null
                }
            }

            DSM.State {
                id: editingNext

                signal noEnabledEditorFound()

                onEntered: {
                    if (frontEditor.faceEnabled) frontEditor.editing = true
                    else if (topEditor.faceEnabled) topEditor.editing = true
                    else if (rightEditor.faceEnabled) rightEditor.editing = true
                    else if (backEditor.faceEnabled) backEditor.editing = true
                    else if (bottomEditor.faceEnabled) bottomEditor.editing = true
                    else if (leftEditor.faceEnabled) leftEditor.editing = true
                    else noEnabledEditorFound()
                }

                DSM.SignalTransition { targetState: editingNone; signal: editingNext.noEnabledEditorFound }
            }

            DSM.State {
                id: editingFront

                onEntered: {
                    topEditor.editing = false
                    rightEditor.editing = false
                    backEditor.editing = false
                    bottomEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = frontEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: frontEditor.editingFinished }
            }

            DSM.State {
                id: editingTop

                onEntered: {
                    frontEditor.editing = false
                    rightEditor.editing = false
                    backEditor.editing = false
                    bottomEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = topEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: topEditor.editingFinished }
            }

            DSM.State {
                id: editingRight

                onEntered: {
                    frontEditor.editing = false
                    topEditor.editing = false
                    backEditor.editing = false
                    bottomEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = rightEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: rightEditor.editingFinished }
            }

            DSM.State {
                id: editingBack

                onEntered: {
                    frontEditor.editing = false
                    topEditor.editing = false
                    rightEditor.editing = false
                    bottomEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = backEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: backEditor.editingFinished }
            }

            DSM.State {
                id: editingBottom

                onEntered: {
                    frontEditor.editing = false
                    topEditor.editing = false
                    rightEditor.editing = false
                    backEditor.editing = false
                    leftEditor.editing = false

                    currentEditor = bottomEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: bottomEditor.editingFinished }
            }

            DSM.State {
                id: editingLeft

                onEntered: {
                    frontEditor.editing = false
                    topEditor.editing = false
                    rightEditor.editing = false
                    backEditor.editing = false
                    bottomEditor.editing = false

                    currentEditor = leftEditor
                }

                DSM.SignalTransition { targetState: editingNext; signal: leftEditor.editingFinished }
            }
        }
    }
}
