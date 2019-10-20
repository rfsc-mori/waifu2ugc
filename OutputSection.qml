import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.1 as Labs

import waifu2ugc 1.0

Item {
    property bool ready: false
    property url outputDirectory

    property string nxl_path: "file:///C:/Nexon/Library/maplestory2/appdata/Custom/Cube"
    property string steam_path: "file:///C:/Program Files (x86)/Steam/steamapps/common/MapleStory 2/Custom/Cube"

    signal showErrors()

    implicitWidth: mainFrame.implicitWidth
    implicitHeight: mainFrame.implicitHeight

    function setNXLpath() {
        if (TemplateExporter.directoryExists(nxl_path))
        {
            outputDirectory = nxl_path
            return true
        }

        return false
    }

    function setSteamPath() {
        if (TemplateExporter.directoryExists(steam_path))
        {
            outputDirectory = steam_path
            return true
        }

        return false
    }

    Component.onCompleted: {
        if (!setNXLpath()) setSteamPath()
    }

    ColumnLayout {
        id: mainFrame
        Layout.fillHeight: true

        GridLayout {
            id: outputDirectorySection
            columns: 3

            Label {
                id: txtOutputDirectory
                text: qsTr("Output directory:")
                Layout.columnSpan: outputDirectorySection.columns
            }

            TextField {
                text: outputDirectory
                placeholderText: qsTr("Please select a directory...")
                selectByMouse: true
                onEditingFinished: {
                    var resolved = Qt.resolvedUrl(text)

                    if (resolved.toString().substring(0, 3) !== "qrc")
                    {
                        outputDirectory = resolved
                    }
                    else
                    {
                        outputDirectory = TemplateExporter.alternativeResolve(text)
                    }
                }
            }

            Button {
                text: qsTr("Open")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.preferredWidth: implicitContentWidth * 2
                onClicked: openDirectory.open()
            }

            Labs.FolderDialog {
                id: openDirectory
                title: qsTr("Please select a directory")
                folder: outputDirectory != "" ? outputDirectory : shortcutsProvider.shortcuts.home
                onAccepted: {
                    outputDirectory = folder
                }

                FileDialog { id: shortcutsProvider }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop

                Button {
                    text: qsTr("NXL")
                    onClicked: setNXLpath()

                    Layout.preferredWidth: btnSteam.width
                    Layout.preferredHeight: implicitContentHeight
                }

                Button {
                    id: btnSteam
                    text: qsTr("Steam")
                    onClicked: setSteamPath()

                    Layout.preferredWidth: implicitContentWidth * 2
                    Layout.preferredHeight: implicitContentHeight
                }
            }
        }

        RowLayout {
            Button {
                id: btnExport
                text: qsTr("Export")
                enabled: ready && outputDirectory != "" && !TemplateExporter.busy
                visible: !TemplateExporter.busy
                onClicked: TemplateExporter.exportToDirectory(outputDirectory)
            }

            Button {
                text: qsTr("Cancel")
                visible: TemplateExporter.busy
                onClicked: TemplateExporter.cancel()
            }

            Button {
                text: qsTr("?")
                enabled: !btnExport.enabled
                onClicked: {
                    if (TemplateExporter.busy)
                    {
                        outputError.message = qsTr("Already exporting. Please wait.")
                        outputError.open()
                    }
                    else if (outputDirectory != "")
                    {
                        showErrors()
                    }
                    else
                    {
                        outputError.message = qsTr("No output directory selected.")
                        outputError.open()
                    }
                }
            }
        }

        Text {
            text: TemplateExporter.statusMessage
            visible: TemplateExporter.busy
            Layout.fillWidth: true
        }

        ProgressBar {
            from: 0
            to: 100
            value: TemplateExporter.progress
            visible: TemplateExporter.busy
            Layout.fillWidth: true
        }

        Popup {
            id: outputError

            property string message

            modal: true
            focus: true
            anchors.centerIn: parent

            contentItem: Text {
                text: outputError.message
                wrapMode: Text.Wrap
            }
        }
    }

    Label {
        text: "Aruraune | Aru#8367 ❤\r\nhttps://gitlab.com/aruraune"
        color: "#FCC6E2"
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
