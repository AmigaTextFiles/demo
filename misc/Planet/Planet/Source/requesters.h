/*  requesters.h
 *
 *  Author: Norman Walter
 *  Date: 5.2.2006
 */

#ifndef REQUESTERS_H
#define REQUESTERS_H

#include <exec/types.h>
#include <intuition/intuition.h>

void MessageBox(char *title, char *message);

void TextureInfo(char *title, char *name, int width, int height);

void LoadError(char *title, char *name);

#endif
