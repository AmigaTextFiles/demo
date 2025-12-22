/* Открытие окна на стандартном общем экране (обычно - это экран Workbench`а) */

MODULE 'intuition/intuition'  -> Нам понадобится модуль intuition.m

ENUM ERR_NONE, ERR_WIN, ERR_KICK, ERR_PUB -> определяем константы перечислением

RAISE ERR_WIN IF OpenWindowTagList()=NIL, -> параметры прерывания: окно не
      ERR_PUB IF LockPubScreen()=NIL      -> открылось или сорвался захват

-> Открываем простое окно и ждем, пока не будет нажат close гэджет

PROC main() HANDLE -> наша процедура имеет обработчик прерываний
  DEF test_window=NIL, test_screen=NIL -> устанавливаем переменные под структуры

  IF KickVersion(37)=FALSE THEN Raise(ERR_KICK) -> проверка кикстарта

  -> Захват стандартного общего экрана
  test_screen:=LockPubScreen('Workbench') -> Экран для захвата

  -> Открываем окно с помощью tag-листа
  test_window:=OpenWindowTagList(NIL,
                                [WA_LEFT,  0,  WA_TOP,    11,
                                 WA_WIDTH, 640, WA_HEIGHT, 30,
                                 WA_DRAGBAR,       TRUE,
                                 WA_CLOSEGADGET,   TRUE,
                                 WA_SMARTREFRESH,  TRUE,
                                 WA_NOCAREREFRESH, TRUE,
                                 WA_DEPTHGADGET,   TRUE,
                                 WA_IDCMP,         IDCMP_CLOSEWINDOW,
                                 WA_TITLE,         'Window Title',
                                 WA_PUBSCREEN,     test_screen,
                                 NIL])

  -> Снятие захвата
  UnlockPubScreen(NIL, test_screen)

  -> Устанавливаем переменную в NIL, для корректной обработки ошибок
  test_screen:=NIL

  -> Уходим в петлю процедуры ожидания события
  handle_window_events(test_window)

  -> Зачистка и выход через обработчик прерываний
EXCEPT DO
  IF test_window THEN CloseWindow(test_window)
  IF test_screen THEN UnlockPubScreen(NIL, test_screen)
  SELECT exception -> выведем сообщение об ошибке
  CASE ERR_KICK; WriteF('Error: Needs Kickstart V37+\n')
  CASE ERR_PUB;  WriteF('Error: Could not lock public screen\n')
  CASE ERR_WIN;  WriteF('Error: Failed to open window\n')
  ENDSELECT
ENDPROC

-> Ожидаем событие, в нашем случае - закрытие окна
PROC handle_window_events(win)
  REPEAT
  UNTIL WaitIMessage(win)=IDCMP_CLOSEWINDOW
ENDPROC
