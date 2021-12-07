//////////////////////////////////////////////////////////////////////////////
//	Copyright � 1999 PHD Computer Consultants Ltd
//
//	PHDIo driver		http://www.phdcc.com/phdio/
/////////////////////////////////////////////////////////////////////////////
//	PHDIoctl.cpp:		DeviceIoControl IOCTL codes supported by PHDIo drivers
/////////////////////////////////////////////////////////////////////////////
//	Version history
//	11-Mar-99	1.0.1	CC	creation
//	1-Apr-99	1.0.2	CC	Commands #defined to make easily usable in C
//	3-May-99	1.0.3	CC	PHDIO_ALREADY_CONNECTED_TO_INT added
/////////////////////////////////////////////////////////////////////////////

//	Return status codes

enum PHD_IO_ERRORS
{
	PHDIO_OK = 0,
	PHDIO_UNRECOGNISED_CMD,				// Unrecognised command
	PHDIO_NO_CMD_PARAMS,				// Command does not have required number of parameters
	PHDIO_NO_OUTPUT_ROOM,				// No room in output buffer
	PHDIO_NO_INTERRUPT,					// PHDIO_IRQ_CONNECT: No interrupt resource given
	PHDIO_ALREADY_CONNECTED_TO_INT,		// PHDIO_IRQ_CONNECT: Already connected to interrupt
	PHDIO_NOT_IN_RANGE,					// PHDIO_IRQ_CONNECT: Interrupt register not in range
	PHDIO_BAD_INTERRUPT_VALUE,			// PHDIO_IRQ_CONNECT: Impossible to get interrupt value with specified mask
	PHDIO_CANNOT_CONNECT_TO_INTERRUPT,	// PHDIO_IRQ_CONNECT: cannot connect to the given interrupt
	PHDIO_CANNOT_RW_NEXT,				// PHDIO_WRITE_NEXT or PHDIO_READ_NEXT: Cannot use in IOCTL_PHDIO_RUN_CMDS call
	PHDIO_NO_DATA_LEFT_TO_TRANSFER,		// PHDIO_WRITE_NEXT or PHDIO_READ_NEXT: No data left to transfer
	PHDIO_DELAY_TOO_LONG,				// Delay must be 60us or smaller
	PHDIO_CANCELLED,					// Command processing stopped as IRP cancelled
	PHDIO_BYTE_CMDS_ONLY,				// Only BYTE/UCHAR size commands are currently supported
};

/////////////////////////////////////////////////////////////////////////////
//	Command codes	reg:	1 byte Offset into address space
//					Value	1/2/4 byte value according to top 2 bits
//					count:	1 byte count
//					seconds:IRQ based read or write timeout

const UCHAR PHDIO_UCHAR = 0x00;
const UCHAR PHDIO_UWORD = 0x40;	// Not implemented yet
const UCHAR PHDIO_ULONG = 0x80;	// Not implemented yet

#ifndef __cplusplus
#define PHDIO_READ_NEXT		11
#define PHDIO_WRITE_NEXT	10
#define PHDIO_TIMEOUT		9
#define PHDIO_IRQ_CONNECT	8
#define PHDIO_READS			7
#define PHDIO_WRITES		6
#define PHDIO_DELAY			5
#define PHDIO_READ			4
#define PHDIO_WRITE			3
#define PHDIO_XOR			2
#define PHDIO_AND			1
#define PHDIO_OR			0
#else
enum PHD_IO_CMDS
{
	PHDIO_OR = 0,		// reg,Value				Use to set bit(s)
	PHDIO_AND,			// reg,Value				Use to clear bit(s)
	PHDIO_XOR,			// reg,Value				Use to toggle bit(s)

	PHDIO_WRITE,		// reg,Value
	PHDIO_READ,			// reg				Value

	PHDIO_DELAY,		// delay					1us units, delay<=60us

	PHDIO_WRITES,		// reg,count,Values,delay	Write values to same reg with delay
	PHDIO_READS,		// reg,count,delay	Values	Read values from same reg with delay

	PHDIO_IRQ_CONNECT,	// reg,mask,Value			Connect to interrupt
						//							on interrupt:	reg read
						//											anded with mask
						//											if equals value then it's ours
						// Usually last cmd in a buffer to make next cmds synchronised

	PHDIO_TIMEOUT,		// seconds					Specify timeout for reads and writes
	PHDIO_WRITE_NEXT,	// reg						Write next value from write buffer
	PHDIO_READ_NEXT,	// reg						Read next value into read buffer
};
#endif

/////////////////////////////////////////////////////////////////////////////
//	IOCTL codes

#define IOCTL_PHDIO_RUN_CMDS CTL_CODE(		\
			FILE_DEVICE_UNKNOWN,			\
			0x801,							\
			METHOD_BUFFERED,				\
			FILE_ANY_ACCESS)

#define IOCTL_PHDIO_CMDS_FOR_READ CTL_CODE(	\
			FILE_DEVICE_UNKNOWN,			\
			0x802,							\
			METHOD_BUFFERED,				\
			FILE_ANY_ACCESS)

#define IOCTL_PHDIO_CMDS_FOR_READ_START CTL_CODE(	\
			FILE_DEVICE_UNKNOWN,			\
			0x803,							\
			METHOD_BUFFERED,				\
			FILE_ANY_ACCESS)

#define IOCTL_PHDIO_CMDS_FOR_WRITE CTL_CODE(\
			FILE_DEVICE_UNKNOWN,			\
			0x804,							\
			METHOD_BUFFERED,				\
			FILE_ANY_ACCESS)

#define IOCTL_PHDIO_GET_RW_RESULTS CTL_CODE(\
			FILE_DEVICE_UNKNOWN,			\
			0x805,							\
			METHOD_BUFFERED,				\
			FILE_ANY_ACCESS)

