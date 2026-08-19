global SETTINGS
dio = digitalio('nidaq',SETTINGS.DAQ_device);
    addline(dio,0:7,'out');
    
    putvalue(dio,0);
    WaitSecs(1);
    putvalue(dio,255);