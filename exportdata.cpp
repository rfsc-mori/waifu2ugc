#include "exportdata.h"

int ExportData::getXAxisSize() const {
	int count = 0;

	for (auto& face : m_faces)
	{
		if (face.enabled() && face.affectsXHorizontally())
		{
			count = std::max(count, face.horizontalCount());
		}
	}

	return count;
}

int ExportData::getYAxisSize() const {
	int count = 0;

	for (auto& face : m_faces)
	{
		if (face.enabled() && face.affectsYVertically())
		{
			count = std::max(count, face.verticalCount());
		}
	}

	return count;
}

int ExportData::getZAxisSize() const {
	int count = 0;

	for (auto& face : m_faces)
	{
		if (face.enabled())
		{
			if (face.affectsZHorizontally())
			{
				count = std::max(count, face.horizontalCount());
			}
			else if (face.affectsZVertically())
			{
				count = std::max(count, face.verticalCount());
			}
		}
	}

	return count;
}
