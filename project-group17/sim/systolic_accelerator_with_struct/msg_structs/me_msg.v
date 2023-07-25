`ifndef ME_MSG_V
`define ME_MSG_V
`include "systolic_accelerator/msg_structs/data_type.v"
//========================================================================
// Memory Engine Recieve Message
//========================================================================
//
// ((((((((((((((((((((change discription here))))))))))))))
//Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//((((((((((((((((((((((((ends))))))))))))))))))))))))
// Message Format:
//
//  DAT_WIDTH  1bit   1bit
//  +--------+------+-----+
//  |  data  | mode | run | 
//  +--------+------+-----+
//   Where DAT_WIDTH = INT_WIDTH + FRAC_WIDTH
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
//  13     2    1        0
//  +--------+------+-----+
//  |  data  | mode | run | 
//  +--------+------+-----+
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

//-----------------------------------------------------------------------------
// Memory Engine Recieve Struct: Using a packed struct to represent the message
//-----------------------------------------------------------------------------

typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] data;
    logic mode;
    logic run;
} memory_engine_recv_msg;

//========================================================================
// Memory Engine Send Message
//========================================================================
//
// ((((((((((((((((((((change discription here))))))))))))))
//Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//((((((((((((((((((((((((ends))))))))))))))))))))))))
// Message Format:
//
//  DAT_WIDTH  
//  +--------+
//  |  data  |
//  +--------+
//   Where DAT_WIDTH = INT_WIDTH + FRAC_WIDTH
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
//  11       0
//  +--------+
//  |  data  |
//  +--------+
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

//-----------------------------------------------------------------------------
// Memory Engine Send Struct: Using a packed struct to represent the message
//-----------------------------------------------------------------------------


typedef struct packed {
    logic [INT_WIDTH + FRAC_WIDTH - 1:0] data;
} memory_engine_send_msg;

`endif /* ME_MSG_V */
