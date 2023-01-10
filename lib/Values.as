array<string> GAMES = {'Trackmania 2020', 'ManiaPlanet 4', 'Trackmania Turbo'};
#if TMNEXT
auto GAME_ID = 0;
#elif MP4
auto GAME_ID = 1;
#elif TURBO
auto GAME_ID = 2;
#endif