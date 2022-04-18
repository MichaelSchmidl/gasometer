#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define Wh_PER_PULSE 113 // 112.7

#define DAILY_ELECTRIC_ENERGY_CONSUMPTION_DB "smartpick/daily.csv"

uint32_t getElectricEnergy( time_t t )
{
   struct tm tm_buf;

   localtime_r(&t, &tm_buf);

   char szDay[20];
   snprintf(szDay, sizeof(szDay), "%d.%d.%d",
            tm_buf.tm_mday,
            tm_buf.tm_mon+1,
            tm_buf.tm_year+1900);
   //printf("[%s] ", szDay);

   FILE *fi = fopen(DAILY_ELECTRIC_ENERGY_CONSUMPTION_DB, "r");
   if ( NULL == fi ) return 0;

   char szLine[100];
   while ( fgets(szLine, sizeof(szLine), fi) != NULL )
   {
      if (!strncmp(szDay, szLine, strlen(szDay) ))
      {
         //printf(" [%s] ", szLine );
         float kWh = 0.0;
         uint32_t Wh = 0;
         char *pkWh = strchr(szLine, ',');
         if (NULL != pkWh)
         {
            pkWh++;
            //printf(" [%s] ", pkWh );
            sscanf(pkWh, "%f", &kWh);
            Wh = (uint32_t)(kWh * 1000.0);
            //printf("=%ld\n", Wh);
         }
         fclose(fi);
         return Wh;
      }
   }
   fclose(fi);
   return 0;
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
   char szLine[100];
   time_t last_t = 0;
   struct tm tm_buf;
   uint32_t Wh = 0;
   uint32_t eWh = 0; // electrical Wh
   uint32_t last_mday = 0;
   uint32_t pulseCnt = 0;
   printf("#timestamp,gWh,pulses,eWh,eWh+gWh,date\n");
   while ( fgets(szLine, sizeof(szLine), fi) != NULL )
   {
      time_t t;
      sscanf( szLine, "%ld", &t );
      localtime_r(&t, &tm_buf);
      if (tm_buf.tm_mday != last_mday)
      {
         if ( 0 != last_t )
         {
            eWh = getElectricEnergy(last_t);
            printf("%ld,%ld,%ld,%ld,%ld,%s", 
                   last_t, 
                   Wh, 
                   pulseCnt, 
                   eWh,
                   Wh+eWh,
                   ctime(&last_t));
         }
         Wh = 0;
         pulseCnt = 0;
      }
      pulseCnt++;
      Wh += Wh_PER_PULSE;
      last_t = t;
      last_mday = tm_buf.tm_mday;
   }
   eWh = getElectricEnergy(last_t);
   printf("%ld,%ld,%ld,%ld,%ld,%s", last_t, Wh, pulseCnt, eWh, Wh+eWh, ctime(&last_t));
   fclose(fi);
   return 0;
}
