#include <stdio.h>
#include <stdlib.h>
#include <pigpio.h>

/*
cc -o LDR LDR.c -lpigpio -lrt -lpthread
*/

#define PULSE_GPIO 21 /* GPIO 21 as interrupt input */

uint32_t pulseCnt = 0;

void healthCheck ( void )
{
   system("curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/6181d426-500e-4540-bd45-ca6c4ae72757");
}


void alert(int pin, int level, uint32_t tick)
{
   if ( level == 0 )
   {
      time_t now;
      time( &now );
      struct tm tm_buf;
      localtime_r(&now, &tm_buf);
      FILE *fo = fopen("gasometerTimestamps.csv", "a");
      fprintf( fo, "%ld,%02d.%02d.%04d_%02d:%02d:%02d\n",
               now,
               tm_buf.tm_mday,
               tm_buf.tm_mon + 1,
               tm_buf.tm_year + 1900,
               tm_buf.tm_hour,
               tm_buf.tm_min,
               tm_buf.tm_sec);
      fclose(fo);
      pulseCnt++;
   }
}


int main (int argc, char *argv[])
{
   if ( gpioInitialise() < 0)
   {
      return 1;
   }

   healthCheck();

   gpioSetAlertFunc(PULSE_GPIO, alert); /* call alert when input changes state */
   gpioSetMode(PULSE_GPIO, PI_INPUT);
   gpioSetPullUpDown(PULSE_GPIO, PI_PUD_UP);

   while (1)
   {
      gpioDelay(3600*1000); //1h
      if ( pulseCnt > 0 ) healthCheck();
      pulseCnt = 0;
   }

   gpioTerminate();
}
