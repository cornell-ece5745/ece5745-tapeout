`ifndef SYSTOLIC_MSGS_V
`define SYSTOLIC_MSGS_V
`include "systolic_accelerator/msg_structs/data_type.v"
//========================================================================
// Systolic Recieve Message
//========================================================================
// ((((((((((((((((((((change discription here))))))))))))))
//Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//((((((((((((((((((((((((ends))))))))))))))))))))))))
// Message Format:
//
//   DAT_WIDTH  DAT_WIDTH  DAT_WIDTH1 DAT_WIDTH   1bit   1bit    1bit
//  +----------+----------+----------+----------+------+-----+-----------+
//  | weight_0 | weight_1 |  data_0  |  data_1  | mode | run | final_run |
//  +----------+----------+----------+----------+------+-----+-----------+
//      Where DAT_WIDTH = INT_WIDTH + FRAC_WIDTH
//
// (((((((((((((((((((((((((((change discription here)))))))))))))))))))))))))))
// The message type is parameterized by the number of bits in the opaque
// field, address field, and data field. Note that the size of the length
// field is caclulated from the number of bits in the data field, and
// that the length field is expressed in _bytes_. If the value of the
// length field is zero, then the read or write should be for the full
// width of the data field.
//((((((((((((((((((((((((((((((((((ends))))))))))))))))))))))))))))))))))

// For example, if the DAT_WIDTH is 12 bits, then the message format is as follows:
//
//  50       39 38      27 26      15 14       3    2     1              0
//  +----------+----------+----------+----------+------+-----+-----------+
//  | weight_0 | weight_1 |  data_0  |  data_1  | mode | run | final_run |
//  +----------+----------+----------+----------+------+-----+-----------+
//   
//(((((((((((((((((((((((((((change description here)))))))))))))))))))))))))))
// The length field is two bits. A length value of one means read or write
// a single byte, a length value of two means read or write two bytes, and
// so on. A length value of zero means read or write all four bytes. Note
// that not all memories will necessarily support any alignment and/or any
// value for the length field.
//
// The opaque field is reserved for use by a specific implementation. All
// memories should guarantee that every response includes the opaque
// field corresponding to the request that generated the response.
//(((((((((((((((((((((((ends)))))))))))))))))))))))

//------------------------------------------------------------------------
// Systolic Recieve Struct: Using a packed struct to represent the message
//------------------------------------------------------------------------

typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] weight_0;
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] weight_1;
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] data_0;
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] data_1;
    logic mode;
    logic run;
    logic final_run;
} systolic_mult_recv_msg;

//========================================================================
// Systolic Send Message
//========================================================================
// ((((((((((((((((((((change discription here))))))))))))))
//Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//((((((((((((((((((((((((ends))))))))))))))))))))))))
// Message Format:
//
//   DAT_WIDTH  DAT_WIDTH  
//  +----------+----------+
//  | result_0 | result_1 | 
//  +----------+----------+
//  Where DAT_WIDTH = INT_WIDTH + FRAC_WIDTH
//
// (((((((((((((((((((((((((((change discription here)))))))))))))))))))))))))))
// The message type is parameterized by the number of bits in the opaque
// field, address field, and data field. Note that the size of the length
// field is caclulated from the number of bits in the data field, and
// that the length field is expressed in _bytes_. If the value of the
// length field is zero, then the read or write should be for the full
// width of the data field.
//((((((((((((((((((((((((((((((((((ends))))))))))))))))))))))))))))))))))

// For example, if the DAT_WIDTH is 12 bits, then the message format is as follows:
//
//  23       12 11        0
//  +----------+----------+
//  | weight_0 | weight_1 |
//  +----------+----------+
//      Where DAT_WIDTH = INT_WIDTH + FRAC_WIDTH
//
//(((((((((((((((((((((((((((change description here)))))))))))))))))))))))))))
// The length field is two bits. A length value of one means read or write
// a single byte, a length value of two means read or write two bytes, and
// so on. A length value of zero means read or write all four bytes. Note
// that not all memories will necessarily support any alignment and/or any
// value for the length field.
//
// The opaque field is reserved for use by a specific implementation. All
// memories should guarantee that every response includes the opaque
// field corresponding to the request that generated the response.
//(((((((((((((((((((((((ends)))))))))))))))))))))))

//------------------------------------------------------------------------
// Systolic Recv Struct: Using a packed struct to represent the message
//------------------------------------------------------------------------

typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] result_0;
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] result_1;
} systolic_mult_send_msg;

`endif /* SYSTOLIC_MSGS_V */