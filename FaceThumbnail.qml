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
    id: thumbnail
    property bool enabled

    property bool current
    property bool ready

    property string faceText
    property rect faceRect

    property url faceImage
    property color baseColor

    property real focusedOpacity: 1
    property real blurredOpacity: 0.75
    property real thumbnailOpacity: 0.75
    property real borderWidth: 3
    property real fontPointSize: 36
    property real textMarginFactor: 0.5

    signal faceClicked

    x: faceRect.x
    y: faceRect.y
    width: faceRect.width
    height: faceRect.height
    visible: false

    Rectangle {
        id: placeholder
        color: baseColor
        anchors.fill: parent
    }

    Image {
        id: preview
        asynchronous: true
        opacity: thumbnailOpacity
        source: faceImage ? faceImage : ""
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
    }

    Rectangle {
        id: border
        color: "transparent"
        visible: false
        anchors.fill: parent

        border {
            color: baseColor
            width: borderWidth
        }
    }

    Label {
        text: faceText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.HorizontalFit

        font {
            bold: true
            pointSize: fontPointSize
        }

        anchors {
            fill: parent
            margins: parent.width * textMarginFactor
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: faceClicked()
    }

    states: [
        State {
            name: "ready and selected"
            when: enabled && current && ready
            PropertyChanges { target: placeholder; visible: preview.status != Image.Ready }
            PropertyChanges { target: thumbnail; visible: true }
            PropertyChanges { target: thumbnail; opacity: focusedOpacity }
            PropertyChanges { target: border; visible: true }
        }
        ,State {
            name: "selected"
            when: enabled && current
            PropertyChanges { target: placeholder; visible: preview.status != Image.Ready }
            PropertyChanges { target: thumbnail; visible: true }
            PropertyChanges { target: thumbnail; opacity: focusedOpacity }
            PropertyChanges { target: border; visible: true }
        }
        ,State {
            name: "ready"
            when: enabled && ready
            PropertyChanges { target: placeholder; visible: true }
            PropertyChanges { target: thumbnail; visible: true }
            PropertyChanges { target: thumbnail; opacity: blurredOpacity }
            PropertyChanges { target: border; visible: false }
        }
        ,State {
            name: "enabled"
            when: enabled
            PropertyChanges { target: placeholder; visible: true }
            PropertyChanges { target: thumbnail; visible: true }
            PropertyChanges { target: thumbnail; opacity: blurredOpacity }
            PropertyChanges { target: border; visible: false }
        }
        ,State {
            name: "disabled"
            when: !enabled
            PropertyChanges { target: placeholder; visible: false }
            PropertyChanges { target: thumbnail; visible: false }
            PropertyChanges { target: thumbnail; opacity: 0 }
            PropertyChanges { target: border; visible: false }
        }
    ]

    transitions: [
        Transition {
            to: "disabled"
            SequentialAnimation {
                NumberAnimation { property: "opacity"; duration: 300 }
                PropertyAction { property: "visible" }
            }
        }
    ]
}
