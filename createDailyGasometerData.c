#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

#define Wh_PER_PULSE 113 // 112.7

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
   char szLine[100];
   time_t last_t = 0;
   struct tm tm_buf;
   uint32_t Wh = 0;
   uint32_t last_mday = 0;
   uint32_t pulseCnt = 0;
   while ( fgets(szLine, sizeof(szLine), fi) != NULL )
   {
      time_t t;
      sscanf( szLine, "%ld", &t );
      localtime_r(&t, &tm_buf);
//      printf("%ld %02d.%02d.%04d_%02d:%02d:%02d\n", t, tm_buf.tm_mday, tm_buf.tm_mon+1, 1900+tm_buf.tm_year, tm_buf.tm_hour, tm_buf.tm_min, tm_buf.tm_sec);
      if (tm_buf.tm_mday != last_mday)
      {
         if ( 0 != last_t )
         {
            printf("%ld,%ld,%ld,%s", last_t, Wh, pulseCnt, ctime(&last_t));
         }
         Wh = 0;
         pulseCnt = 0;
      }
      pulseCnt++;
      Wh += Wh_PER_PULSE;
      last_t = t;
      last_mday = tm_buf.tm_mday;
   }
   printf("%ld,%ld,%ld,%s", last_t, Wh, pulseCnt, ctime(&last_t));
   fclose(fi);
   return 0;
}

