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

import waifu2ugc 1.0

Window {
    title: qsTr("waifu2ugc")
    visible: true

    minimumWidth: mainFrame.implicitWidth
    minimumHeight: mainFrame.implicitHeight

    Component.onCompleted: {
        setX(Screen.width / 2 - minimumWidth / 2);
        setY(Screen.height / 2 - minimumHeight / 2);
    }

    onClosing: TemplateExporter.cancel()

    RowLayout {
        id: mainFrame

        anchors.fill: parent

        InputSection {
            id: inputSection

            Layout.minimumHeight: Math.max(implicitHeight, 890)
            Layout.fillHeight: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5
        }

        FacesSection {
            id: facesSection
            currentEditor: inputSection.currentEditor

            frontEditor: inputSection.editors["front"]
            topEditor: inputSection.editors["top"]
            rightEditor: inputSection.editors["right"]
            backEditor: inputSection.editors["back"]
            bottomEditor: inputSection.editors["bottom"]
            leftEditor: inputSection.editors["left"]

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 480
            Layout.minimumHeight: implicitHeight
        }

        OutputSection {
            ready: inputSection.ready

            Layout.fillHeight: true
            Layout.rightMargin: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Layout.minimumHeight: implicitHeight

            onShowErrors: {
                statusAlert.message = inputSection.getErrors().join("\r\n\r\n")
                statusAlert.open()
            }
        }

        Connections {
            target: TemplateExporter

            onError: {
                statusAlert.message = error
                statusAlert.open()
            }

            onFinished: {
                if (!TemplateExporter.canceled)
                {
                    statusAlert.message = qsTr("waifu2ugc finished exporting all images!")
                    statusAlert.open()
                }
            }
        }

        Popup {
            id: statusAlert

            property string message

            modal: true
            focus: true
            anchors.centerIn: parent

            contentItem: TextArea {
                text: statusAlert.message
                implicitWidth: facesSection.width
                wrapMode: Text.Wrap
            }
        }
    }
}
