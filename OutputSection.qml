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
        text: "Aruraune | Aru#8367 ❤\r\nhttps://gitlab.com/aruraune\r\n\r\nClick for more info."
        color: "#FCC6E2"
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        MouseArea {
            anchors.fill: parent
            onClicked: aboutDialog.open()
        }
    }

    MessageDialog {
        id: aboutDialog
        title: "About"
        text: "This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. (http://www.openssl.org/)" +
              "\r\n\r\n" +
              "This product includes software written by Eric Young (eay@cryptsoft.com)" +
              "\r\n\r\n" +
              "This product includes software written by Tim Hudson (tjh@cryptsoft.com)" +
              "\r\n\r\n" +
              "This program uses Qt version 5.13." + "\r\n\r\n" +
              "Qt is a C++ toolkit for cross-platform application development." + "\r\n" +
              "Qt provides single-source portability across all major desktop " +
              "operating systems. It is also available for embedded Linux and other " +
              "embedded and mobile operating systems." + "\r\n" +
              "Qt is available under three different licensing options designed " +
              "to accommodate the needs of our various users." + "\r\n" +
              "Qt licensed under our commercial license agreement is appropriate " +
              "for development of proprietary/commercial software where you do not " +
              "want to share any source code with third parties or otherwise cannot " +
              "comply with the terms of the GNU LGPL version 3 or GNU LGPL version 2.1." + "\r\n" +
              "Qt licensed under the GNU LGPL version 3 is appropriate for the " +
              "development of Qt&nbsp;applications provided you can comply with the terms " +
              "and conditions of the GNU LGPL version 3." + "\r\n" +
              "Qt licensed under the GNU LGPL version 2.1 is appropriate for the " +
              "development of Qt&nbsp;applications provided you can comply with the terms " +
              "and conditions of the GNU LGPL version 2.1." + "\r\n" +
              "Please see http://qt.io/licensing " +
              "for an overview of Qt licensing." + "\r\n" +
              "Copyright (C) 2019 The Qt Company Ltd and other " +
              "contributors." + "\r\n" +
              "Qt and the Qt logo are trademarks of The Qt Company Ltd." + "\r\n" +
              "Qt is The Qt Company Ltd product developed as an open source " +
              "project. See http://qt.io/ for more information."
    }
}
