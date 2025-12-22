//-------------------------------------------------------------------
//	File:		Texture.h
//	Created:	05/26/99 2:30:AM
//	Author:		Aaron Hilton
//	Comments:	Create and manage OpenGL textures.
//-------------------------------------------------------------------
#ifndef __Texture_h_
#define __Texture_h_

#define MAX_TEXTURE_NAME_LENGTH 64

class CTexture
{
public:
	CTexture();
	~CTexture();

	// Create and load the files.
	bool LoadBMP(char* szFileName);
    bool LoadJPG(char* szFileName, bool asAlpha = false);

	void Toast();

	void Use();

protected:
	// Generates the nesessary internal data.
	bool Create(char* szFileName);

	char m_szName[MAX_TEXTURE_NAME_LENGTH];
	unsigned int m_nID;

	// Status information.
	int m_nWidth, m_nHeight;
};

#endif // __Texture_h_
//-------------------------------------------------------------------
//	History:
//	$Log:$
//-------------------------------------------------------------------
