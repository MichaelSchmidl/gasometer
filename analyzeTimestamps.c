#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

#define Wh_PER_PULSE 113 // 112.7

uint32_t lineNr = 0;
char szLine[100];
time_t last_t = 0;
struct tm tm_buf;
uint32_t Wh = 0;
time_t min_dT = 999999999;
time_t max_dT = 0;
time_t dT = 0;
uint32_t watt = 0;
time_t min_W = 999999999;
time_t max_W = 0;

void showValues( void )
{
   printf("%ld", lineNr);
   printf(",%5ld,%5ld,%5ld,%5ld", watt, min_W, max_W, dT);
   printf(",%d,%02d:%02d", min_dT, min_dT / 60, min_dT % 60);
   printf(",%d,%02d:%02d", max_dT, max_dT / 60, max_dT % 60);
   printf("\n");
}


int main( int argc, char **argv )
{
   time_t current_time = time(NULL);
//   printf("now=%ld\n", current_time);

   FILE *fi = fopen(argv[1],"r");
   if ( NULL == fi )
   {
      perror(argv[1]);
      return 1;
   }
   while ( fgets(szLine, sizeof(szLine), fi) != NULL )
   {
      time_t t;
      sscanf( szLine, "%ld", &t );
      lineNr++;
      localtime_r(&t, &tm_buf);
      dT = t - last_t;
      watt = 3600 * Wh_PER_PULSE / dT;
      if ( 0 != last_t )
      {
         if ( dT > max_dT ) max_dT = dT;
         if ( dT < min_dT ) min_dT = dT;
         if ( watt > max_W ) max_W = watt;
         if ( watt < min_W ) min_W = watt;
         showValues();
      }
      last_t = t;
   }
   fclose(fi);
   showValues();
   return 0;
}

