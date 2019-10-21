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

#ifndef EXPORTDATA_H
#define EXPORTDATA_H

#include "templatedata.h"
#include "facedata.h"

#include <QMap>

class ExportData
{
public:
	TemplateData& source()				{ return m_template; }
	const TemplateData& source() const	{ return m_template; }

	FaceData& front()					{ return m_faces[FaceData::FRONT]; }
	FaceData front() const				{ return m_faces[FaceData::FRONT]; }

	FaceData& top()						{ return m_faces[FaceData::TOP]; }
	FaceData top() const				{ return m_faces[FaceData::TOP]; }

	FaceData& right()					{ return m_faces[FaceData::RIGHT]; }
	FaceData right() const				{ return m_faces[FaceData::RIGHT]; }

	FaceData& back()					{ return m_faces[FaceData::BACK]; }
	FaceData back() const				{ return m_faces[FaceData::BACK]; }

	FaceData& bottom()					{ return m_faces[FaceData::BOTTOM]; }
	FaceData bottom() const				{ return m_faces[FaceData::BOTTOM]; }

	FaceData& left()					{ return m_faces[FaceData::LEFT]; }
	FaceData left() const				{ return m_faces[FaceData::LEFT]; }

	FaceData& face(FaceData::FaceIndex index)		{ return m_faces[index]; }
	FaceData face(FaceData::FaceIndex index) const	{ return m_faces[index]; }

	const auto& faces() const { return m_faces; }

	int getXAxisSize() const;
	int getYAxisSize() const;
	int getZAxisSize() const;

private:
	TemplateData m_template;

	QMap<FaceData::FaceIndex, FaceData> m_faces {
		{ FaceData::FRONT, {} },
		{ FaceData::TOP, {} },
		{ FaceData::RIGHT, {} },
		{ FaceData::BACK, {} },
		{ FaceData::BOTTOM, {} },
		{ FaceData::LEFT, {} }
	};
};

#endif // EXPORTDATA_H
