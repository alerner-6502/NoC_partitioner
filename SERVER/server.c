#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 

#include <fcntl.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"

#include "hps_0.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )


void error(const char *msg){
    perror(msg);
    exit(1);
}

int main(int argc, char *argv[])
{
	//--------------- Bridge variables
	
	void *virtual_base;
	int fd;
	
	void *h2p_lw_led_addr;
	void *h2p_lw_switch_addr;
	
	uint32_t switch_state  = 0x0;
	uint32_t led_state = 0x0;
	
	//---------------- Bridge setup
	
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}

	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );

	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	
	// get pointers
	
	h2p_lw_led_addr    = virtual_base + ( (uint32_t)(ALT_LWFPGASLVS_OFST + LED_PIO_BASE)    & (uint32_t)(HW_REGS_MASK) );
	h2p_lw_switch_addr = virtual_base + ( (uint32_t)(ALT_LWFPGASLVS_OFST + DIPSW_PIO_BASE)  & (uint32_t)(HW_REGS_MASK) );
	
	//---------------- Socket variables
	
    int sockfd, newsockfd, portno, n;
    socklen_t clilen;
    struct sockaddr_in serv_addr, cli_addr;
	char buffer[256];
	
	//---------------- Socket parameters
		  
    if (argc < 2) {
        fprintf(stderr,"ERROR, no port provided\n");
        exit(1);
    }
	 
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
	 
    if (sockfd < 0){ error("ERROR opening socket");}
	 
    bzero((char *) &serv_addr, sizeof(serv_addr));
	 
    portno = atoi(argv[1]);
	
	//----------------- Socket setup
	 
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
	 
    if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0){
        error("ERROR on binding");
	}
	
	clilen = sizeof(cli_addr);
	
    listen(sockfd,5);
	
    newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
	
    if (newsockfd < 0){ error("ERROR on accept");}
	
	//---------------- Main loop
	
	printf("Running...");
	
	while(1){
		
		// wait for message from client
		
		n = read(newsockfd, buffer, 255);
		if (n < 0){ error("ERROR reading from socket");}
		
		// read buffer and set leds
		
		led_state = (uint32_t)(buffer[1] << 8) + (uint32_t)(buffer[0]);
		
		alt_write_word(h2p_lw_led_addr, led_state);
		
		// read switches and prepare buffer
		
		switch_state = alt_read_word(h2p_lw_switch_addr) & 0x3ff;
		
		buffer[0] = (char)(switch_state & 0xff);
		buffer[1] = (char)(switch_state >> 8);
		buffer[2] = 0x00;
		
		// send responce to client
		
		n = write(newsockfd, buffer, 3);
		if (n < 0){ error("ERROR writing to socket");}
		
	}
	
	printf("Done\n");
	
    close(newsockfd);
    close(sockfd);
	
    return 0; 
}






