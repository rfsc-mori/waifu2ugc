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
    property FaceEditor currentEditor

    property FaceEditor frontEditor
    property FaceEditor topEditor
    property FaceEditor rightEditor
    property FaceEditor backEditor
    property FaceEditor bottomEditor
    property FaceEditor leftEditor

    RowLayout {
        id: mainFrame
        anchors.fill: parent

        FaceView {
            id: frontView
            editor: frontEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        FaceView {
            id: topView
            editor: topEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        FaceView {
            id: rightView
            editor: rightEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        FaceView {
            id: backView
            editor: backEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        FaceView {
            id: bottomView
            editor: bottomEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        FaceView {
            id: leftView
            editor: leftEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Image {
            id: placeholder
            asynchronous: true
            source: "images/background.png"
            fillMode: Image.Tile
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    states: [
        State {
            name: "front"
            when: currentEditor == frontEditor
            PropertyChanges { target: frontView; visible: true }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "top"
            when: currentEditor == topEditor
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: true }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "right"
            when: currentEditor == rightEditor
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: true }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "back"
            when: currentEditor == backEditor
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: true }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "bottom"
            when: currentEditor == bottomEditor
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: true }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "left"
            when: currentEditor == leftEditor
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: true }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "none"
            when: currentEditor == null
            PropertyChanges { target: frontView; visible: false }
            PropertyChanges { target: topView; visible: false }
            PropertyChanges { target: rightView; visible: false }
            PropertyChanges { target: backView; visible: false }
            PropertyChanges { target: bottomView; visible: false }
            PropertyChanges { target: leftView; visible: false }
            PropertyChanges { target: placeholder; visible: true }
        }
    ]
}
