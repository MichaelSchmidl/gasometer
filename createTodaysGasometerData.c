#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

#define Wh_PER_PULSE 113 // 112.7

#define HEIZUNG_MAX_W 17000
#define HEIZUNG_MIN_W 16000

#define WASSER_MAX_W   7000
#define WASSER_MIN_W   6000

#define KOCHEN_MAX_W   2000
#define KOCHEN_MIN_W   1000

uint32_t h_flag = 0;
uint32_t w_flag = 0;
uint32_t k_flag = 0;

uint32_t kochenW = 0;
uint32_t heizungW = 0;
uint32_t wasserW=0;
uint32_t sonstigesW=0;

void calcVerbraucher( uint32_t w )
{
   uint32_t sum = 0;
   h_flag = 0;
   w_flag = 0;
   k_flag = 0;

   if ( w >= (HEIZUNG_MIN_W + WASSER_MIN_W + KOCHEN_MIN_W ))
   {
      sum = (HEIZUNG_MIN_W + WASSER_MIN_W + KOCHEN_MIN_W);
      h_flag = 1;
      heizungW += (HEIZUNG_MIN_W * w) / sum;
      w_flag = 1;
      wasserW += (WASSER_MIN_W * w) / sum;
      k_flag = 1;
      kochenW += (KOCHEN_MIN_W * w) / sum;
   }
   else if ( w >= (HEIZUNG_MIN_W + WASSER_MIN_W))
   {
      sum = (HEIZUNG_MIN_W + WASSER_MIN_W);
      h_flag = 1;
      heizungW += (HEIZUNG_MIN_W * w) / sum;
      w_flag = 1;
      wasserW += (WASSER_MIN_W * w) / sum;
      k_flag = 0;
      kochenW += (KOCHEN_MIN_W * w) / sum;
   }
   else if ( w >= (HEIZUNG_MIN_W + KOCHEN_MIN_W))
   {
      sum = (HEIZUNG_MIN_W + KOCHEN_MIN_W);
      h_flag = 1;
      heizungW += (HEIZUNG_MIN_W * w) / sum;
      w_flag = 0;
      k_flag = 1;
      kochenW += (KOCHEN_MIN_W * w) / sum;
   }
   else if ( w >= (HEIZUNG_MIN_W))
   {
      sum = (HEIZUNG_MIN_W);
      h_flag = 1;
      heizungW += (HEIZUNG_MIN_W * w) / sum;
      w_flag = 0;
      k_flag = 0;
   }
   else if ( w >= (WASSER_MIN_W + KOCHEN_MIN_W))
   {
      sum = (WASSER_MIN_W + KOCHEN_MIN_W);
      h_flag = 0;
      w_flag = 1;
      wasserW += (WASSER_MIN_W * w) / sum;
      k_flag = 1;
      kochenW += (KOCHEN_MIN_W * w) / sum;
   }
   else if ( w >= (WASSER_MIN_W))
   {
      sum = (WASSER_MIN_W);
      h_flag = 0;
      w_flag = 1;
      wasserW += (WASSER_MIN_W * w) / sum;
      k_flag = 0;
   }
   else if ( w >= (KOCHEN_MIN_W))
   {
      sum = (KOCHEN_MIN_W);
      h_flag = 0;
      w_flag = 0;
      k_flag = 1;
      kochenW += (KOCHEN_MIN_W * w) / sum;
   }
   else
   {
      sonstigesW += w;
   }
}


int main( int argc, char **argv )
{
   time_t current_time = time(NULL);
   struct tm tm_today;
   localtime_r(&current_time, &tm_today);
   
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
   uint32_t total_Wh = 0;
   uint32_t watt = 0;
   uint32_t pulseCnt = 0;
   while ( fgets(szLine, sizeof(szLine), fi) != NULL )
   {
      time_t t;
      sscanf( szLine, "%ld", &t );
      localtime_r(&t, &tm_buf);
      if ( (tm_buf.tm_mday == tm_today.tm_mday) &&
           (tm_buf.tm_mon == tm_today.tm_mon) &&
           (tm_buf.tm_year == tm_today.tm_year) )
      {
         pulseCnt++;
         total_Wh += Wh_PER_PULSE;
         watt = 3600 * Wh_PER_PULSE / (t - last_t);
         calcVerbraucher( Wh_PER_PULSE );
         time_t fakeUTCt = t + 3600; // gnuplot interprets time always as UTC
         if (tm_buf.tm_isdst)
         {
            fakeUTCt += 3600;
         }
         printf("%ld,%5ld,%ld,%ld,[%c%c%c] [%ld %ld %ld %ld]%s",
                fakeUTCt, 
                watt, 
                total_Wh, 
                pulseCnt, 
                h_flag?'h':'-', 
                w_flag?'w':'-', 
                k_flag?'k':'-',
                heizungW,
                wasserW,
                kochenW,
                sonstigesW,
                ctime(&last_t));
      }
      last_t = t;
   }
   fclose(fi);
   return 0;
}

