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

ListModel {	
	ListElement {
        text: qsTr("Block")
		name: "block"
		
        front:  "288, 442, 224, 223" // 288,442 512,665
        top:    "288, 216, 225, 225" // 288,216 513,441
        right:  "513, 442, 228, 223" // 513,442 741,665
        back:   "741, 442, 226, 223" // 741,442 967,665
        bottom: "514, 666, 226, 225" // 514,666 740,891
        left:   " 58, 441, 229, 224" //  58,441 287,665
		
        image: "images/template.png"
	}

    ListElement {
        text: qsTr("Block 226x226")
        name: "block"

        front:  "288, 442, 226, 226"
        top:    "288, 216, 226, 226"
        right:  "513, 442, 226, 226"
        back:   "741, 442, 226, 226"
        bottom: "514, 666, 226, 226"
        left:   " 58, 441, 226, 226"

        image: "images/template.png"
    }

    ListElement {
        text: qsTr("Block 228x228")
        name: "block"

        front:  "288, 442, 228, 228"
        top:    "288, 216, 228, 228"
        right:  "513, 442, 228, 228"
        back:   "741, 442, 228, 228"
        bottom: "514, 666, 228, 228"
        left:   " 58, 441, 228, 228"

        image: "images/template.png"
    }

    ListElement {
        text: qsTr("Block 230x230")
        name: "block"

        front:  "288, 442, 230, 230"
        top:    "288, 216, 230, 230"
        right:  "513, 442, 230, 230"
        back:   "741, 442, 230, 230"
        bottom: "514, 666, 230, 230"
        left:   " 58, 441, 230, 230"

        image: "images/template.png"
    }

    ListElement {
        text: qsTr("Triangle")
        name: "block"

        front:  "576, 436, 347, 247" // 576,436 923,683
        top:    "  0,   0,   0,   0" // unused
        right:  "  0,   0,   0,   0" // unused
        back:   "  0,   0,   0,   0" // unused
        bottom: "  0,   0,   0,   0" // unused
        left:   "  0,   0,   0,   0" // unused

        image: "images/template.png"
    }

    ListElement {
        text: qsTr("Triangle 349x249")
        name: "block"

        front:  "576, 436, 349, 249"
        top:    "  0,   0,   0,   0"
        right:  "  0,   0,   0,   0"
        back:   "  0,   0,   0,   0"
        bottom: "  0,   0,   0,   0"
        left:   "  0,   0,   0,   0"

        image: "images/template.png"
    }

    ListElement {
        text: qsTr("Triangle 350x250")
        name: "block"

        front:  "576, 436, 350, 250"
        top:    "  0,   0,   0,   0"
        right:  "  0,   0,   0,   0"
        back:   "  0,   0,   0,   0"
        bottom: "  0,   0,   0,   0"
        left:   "  0,   0,   0,   0"

        image: "images/template.png"
    }
	
	ListElement {
		text: qsTr("Custom")
		name: "custom"
		
		custom: true

        image: "images/template.png"
	}
}
