#define SONGNAME_LENGTH  1024

enum {
    COMMAND_PLAY=0,
    COMMAND_LOADING,
    COMMAND_EXIT,
    COMMAND_PAUSE,
    COMMAND_NEXT,
    COMMAND_PREV,
    COMMAND_STOP,
    COMMAND_NEW_SONG
};

enum {
    STATUS_STOPPED=0,
    STATUS_PLAYING,
    STATUS_PAUSED
};

struct CommandMessage {
    struct Message commandMsg;
    int            command;
    char           songName[SONGNAME_LENGTH];
};


