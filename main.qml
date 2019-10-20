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
