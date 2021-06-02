#include <stdio.h>
#include <math.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_native_dialog.h>
#include "head.h"


int main(int argc, char* argv[])
{
        unsigned char header[54];

        FILE * file;
        file = fopen("source.bmp", "rb");

        for(int i = 0 ; i < 54 ; i++)
                header[i] = fgetc(file);

        int offset = header[11] * 0x100 + header[10];
        int width = header[19] * 0x100 + header[18];
        int height = header[23] * 0x100 + header[22];
        long long size = header[36] * 0x10000 + header[35] * 0x100 + header[34];

        int padding = (width * 3 + 3) & ~3;

        unsigned char extraSpace [offset - 54];
        unsigned char sourceBitmap[size];
        unsigned char bitmap[size]; 

        for(int i = 0 ; i < offset - 54 ; i++)
                extraSpace[i] = fgetc(file);

        for(long long i = 0 ; i < size ; i++)
        {
                sourceBitmap[i] = fgetc(file);
                bitmap[i] = fgetc(file);
        }


        fclose(file);

        ALLEGRO_DISPLAY *display = NULL;
        ALLEGRO_EVENT_QUEUE *eventQueue = NULL;
        ALLEGRO_BITMAP *bitmapa = NULL; 
        
        if(!al_init())
                exit(-1);
        al_install_mouse();
        al_init_image_addon();
        
        bitmapa = al_load_bitmap("source.bmp");

        display = al_create_display(800, 600);
        eventQueue = al_create_event_queue();
        al_set_target_backbuffer(display);

        al_register_event_source(eventQueue, al_get_display_event_source(display));
        al_register_event_source(eventQueue, al_get_mouse_event_source());

        al_draw_bitmap(bitmapa, 0, 0, 0);
        al_flip_display();
        
        int xPoints[5];
        int yPoints[5];
        int counter = 0;
        while(true)
        {
                
                ALLEGRO_EVENT event;
                al_wait_for_event(eventQueue, &event);

                switch (event.type)
                {
                case ALLEGRO_EVENT_DISPLAY_CLOSE:
                        exit(0);

                case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:

                        if(counter >= 5)
                        {
                                counter = 0;
                                for(int i = 0 ; i < size; i++)
                                        bitmap[i] = sourceBitmap[i];
                        } 

                        xPoints[counter] = event.mouse.x;
                        yPoints[counter] = 600 - event.mouse.y;

                        draw_bezier(xPoints, yPoints, bitmap, counter);

                        file = fopen("result.bmp", "wb");
                        for(int i = 0; i < 54; i++)
                                fputc(header[i], file);

                        for(int i = 0; i < offset - 54; i++)
                                fputc(extraSpace[i], file);

                        for(int i = 0; i < size; i++)
                                fputc(bitmap[i], file);

                        fclose(file);

                        bitmapa = al_load_bitmap("result.bmp");
                        al_draw_bitmap(bitmapa, 0, 0, 0);
                        al_flip_display();

                        counter++;
                }
        } 



}
