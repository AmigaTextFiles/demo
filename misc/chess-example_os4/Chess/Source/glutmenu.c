/* Missing TinyGL Utility Toolkit functions
 * © by Stefan Haubenthal 2007
 */

int glutExtensionSupported(char *extension);
int glutCreateMenu(void (*func)(int));
void glutAddMenuEntry(char *name, int value);

int glutExtensionSupported(char *extension)
{
return !0;
}
int glutCreateMenu(void (*func)(int))
{
return 1;
}
void glutAddMenuEntry(char *name, int value){}
void glutAttachMenu(int button){}
