`ifndef WRAPPER_MSG_V
`define WRAPPER_MSG_V
`include "systolic_accelerator/msg_structs/data_type.v"
//========================================================================
// Memory Request Message
//========================================================================
// Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//
// Message Format:
//
//    4b    p_opaque_nbits  p_addr_nbits       calc   p_data_nbits
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The message type is parameterized by the number of bits in the opaque
// field, address field, and data field. Note that the size of the length
// field is caclulated from the number of bits in the data field, and
// that the length field is expressed in _bytes_. If the value of the
// length field is zero, then the read or write should be for the full
// width of the data field.
//
// For example, if the opaque field is 8 bits, the address is 32 bits and
// the data is also 32 bits, then the message format is as follows:
//
//   77  74 73           66 65              34 33  32 31               0
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The length field is two bits. A length value of one means read or write
// a single byte, a length value of two means read or write two bytes, and
// so on. A length value of zero means read or write all four bytes. Note
// that not all memories will necessarily support any alignment and/or any
// value for the length field.
//
// The opaque field is reserved for use by a specific implementation. All
// memories should guarantee that every response includes the opaque
// field corresponding to the request that generated the response.

//------------------------------------------------------------------------
// Memory Request Struct: Using a packed struct to represent the message
//------------------------------------------------------------------------

parameter NUMCHIP = 4;
parameter DATA_ENTRIES = 2;
parameter DATA_LAT = 0;
parameter SYSTOLIC_SIZE = 2;
parameter SYSTOLIC_STEP_SIZE = DATA_ENTRIES;

typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] data;
    logic [NUMCHIP-1:0] chip_select;
    logic mode;
    logic run;
    logic final_run;
} wrapper_recv_msg;

typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] result_0;
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] result_1;
} wrapper_send_msg;


`endif /* WRAPPER_MSG_V */
