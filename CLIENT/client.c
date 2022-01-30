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
    exit(0);
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
	
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char buffer[256];
	
	//---------------- Socket parameters
	
    if (argc < 3) {
       fprintf(stderr,"usage %s hostname port\n", argv[0]);
       exit(0);
    }
	
    portno = atoi(argv[2]);
	
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
	
    if (sockfd < 0){ error("ERROR opening socket");}
	
    server = gethostbyname(argv[1]);
	
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }
	
	//----------------- Socket setup
	
    bzero((char *) &serv_addr, sizeof(serv_addr));
	
    serv_addr.sin_family = AF_INET;
	
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
    
	serv_addr.sin_port = htons(portno);
	
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0){
        error("ERROR connecting");
	}
	
	//---------------- Main loop
	
	printf("Running...");
	
	while(1){
		
		// read switches and prepare buffer
		
		switch_state = alt_read_word(h2p_lw_switch_addr) & 0x3ff;
		
		buffer[0] = (char)(switch_state & 0xff);
		buffer[1] = (char)(switch_state >> 8);
		buffer[2] = 0x00;
		
		// write data to server
		
		n = write(sockfd, buffer, 3);
		if (n < 0){ error("ERROR writing to socket");}
		
		// wait for responce from server
		
		n = read(sockfd, buffer, 255);
		if (n < 0){ error("ERROR reading from socket");}
		
		// read buffer and set leds
		
		led_state = (uint32_t)(buffer[1] << 8) + (uint32_t)(buffer[0]);
		
		alt_write_word(h2p_lw_led_addr, led_state);
		
		// delay
		
		usleep(200*1000);  // 200ms delay
		
	}
	
	printf("Done\n");
	
    close(sockfd);
	
    return 0;
}
