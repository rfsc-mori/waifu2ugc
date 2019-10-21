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
    property int horizontalCount
    property int verticalCount

    property size faceSize
    property size scaledFaceSize: Qt.size(faceSize.width * width / (faceSize.width * horizontalCount),
                                          faceSize.height * height / (faceSize.height * verticalCount))
    property real lineWidth: 1
    property string strokeStyle: "black"

    onScaledFaceSizeChanged: Qt.callLater(gridCanvas.requestPaint)

    Canvas {
        id: gridCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")

            if (horizontalCount > 1 || verticalCount > 1)
            {
                ctx.lineWidth = lineWidth
                ctx.strokeStyle = strokeStyle

                ctx.beginPath()

                for (var h = 1; h < horizontalCount; ++h)
                {
                    ctx.moveTo(scaledFaceSize.width * h, 0)
                    ctx.lineTo(scaledFaceSize.width * h, height)
                }

                for (var v = 1; v < verticalCount; ++v)
                {
                    ctx.moveTo(0, scaledFaceSize.height * v)
                    ctx.lineTo(width, scaledFaceSize.height * v)
                }

                ctx.closePath()
                ctx.stroke()
            }
            else
            {
                ctx.reset()
            }
        }
    }
}
