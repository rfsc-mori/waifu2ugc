#ifndef FACEDATA_H
#define FACEDATA_H

#include <QString>
#include <QRect>
#include <QUrl>

class FaceData
{
public:
	enum FaceIndex {
		INVALID,
		FRONT,
		TOP,
		RIGHT,
		BACK,
		BOTTOM,
		LEFT
	};

	QString& face()						{ return m_face; }
	const QString& face() const			{ return m_face; }

	FaceIndex& index()					{ return m_index; }
	const FaceIndex& index() const		{ return m_index; }

	QString& text()						{ return m_text; }
	const QString& text() const			{ return m_text; }

	bool& enabled()						{ return m_faceEnabled; }
	bool enabled() const				{ return m_faceEnabled; }

	QRect& faceRect()					{ return m_faceRect; }
	const QRect& faceRect() const		{ return m_faceRect; }

	int& horizontalCount()				{ return m_horizontalCount; }
	int horizontalCount() const			{ return m_horizontalCount; }

	int& verticalCount()				{ return m_verticalCount; }
	int verticalCount() const			{ return m_verticalCount; }

	QUrl& faceImageUrl()				{ return m_faceImageUrl; }
	const QUrl& faceImageUrl() const	{ return m_faceImageUrl; }

	bool& resizeSource()				{ return m_resizeSource; }
	bool resizeSource() const			{ return m_resizeSource; }

	bool& preserveAspectRatio()			{ return m_preserveAspectRatio; }
	bool preserveAspectRatio() const	{ return m_preserveAspectRatio; }

	int& aspectRatioAction()			{ return m_aspectRatioAction; }
	int aspectRatioAction() const		{ return m_aspectRatioAction; }

	QRect& fitRect()					{ return m_fitRect; }
	const QRect& fitRect() const		{ return m_fitRect; }

	QRect& cropRect()					{ return m_cropRect; }
	const QRect& cropRect() const		{ return m_cropRect; }

	bool affectsXHorizontally() const	{ return m_index == FRONT || m_index == TOP   || m_index == BACK || m_index == BOTTOM; }
	bool affectsXVertically() const		{ return false; }
	bool affectsYHorizontally() const	{ return false; }
	bool affectsYVertically() const		{ return m_index == FRONT || m_index == RIGHT || m_index == BACK || m_index == LEFT; }
	bool affectsZHorizontally() const	{ return m_index == RIGHT || m_index == LEFT;   }
	bool affectsZVertically() const		{ return m_index == TOP   || m_index == BOTTOM; }

private:
	QString m_face;
	FaceIndex m_index = INVALID;

	QString m_text;

	bool m_faceEnabled = false;

	QRect m_faceRect;

	int m_horizontalCount = 0;
	int m_verticalCount = 0;

	QUrl m_faceImageUrl;

	bool m_resizeSource = false;
	bool m_preserveAspectRatio = false;

	int m_aspectRatioAction = 0;

	QRect m_fitRect;
	QRect m_cropRect;
};

#endif // FACEDATA_H
