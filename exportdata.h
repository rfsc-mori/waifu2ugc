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
