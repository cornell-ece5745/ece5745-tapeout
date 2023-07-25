module SystolicMultControl #(
// parameter for fixed point number, default is 11.5 (include sign bit)
 parameter SYSTOLIC_SIZE,
 parameter SYSTOLIC_STEP_SIZE
)
(input logic clk,
 input logic reset,
 input logic run,
 input logic final_run,
 output logic shift_result,
 output logic finished,
 output logic val,
 output logic ready,
 output logic produce_run
 );

logic [$clog2(SYSTOLIC_STEP_SIZE*2) - 1 : 0] count;
logic count_start;
always@(posedge clk) begin
    if (reset)
        count <= 'b0;
    else
        count <=  count_start ? count + 1'b1 : 0;
end

typedef enum
{ STATE_WAIT,
  STATE_RUN,
  STATE_RUN_CONTINUOUS,
  STATE_FINISH,
  STATE_FINISHWAIT,
  STATE_SHIFT,
  STATE_SHIFTWAIT0,
  STATE_SHIFTWAIT1,
  STATE_READ_VAL} states;

states current_state, next_state;

logic run_done;
assign run_done =  (count == SYSTOLIC_STEP_SIZE-2) && current_state == STATE_RUN;
logic finish_done;
assign finish_done =  (count == (SYSTOLIC_STEP_SIZE-2+SYSTOLIC_SIZE))  && current_state == STATE_FINISH;

always @( posedge clk ) begin
  if ( reset )
    current_state <= STATE_WAIT;
  else
    current_state <= next_state;
end

always@(*) begin
  next_state = current_state;
  shift_result = 'b0;
  finished = 'b0;
  count_start = 'b0;
  ready = 'b0;
  val = 'b0;
  produce_run = 'b0;
  case ( current_state )
    STATE_WAIT: begin
      if (run) begin
        if (final_run) next_state = STATE_RUN;
        else next_state = STATE_RUN_CONTINUOUS;
      end
      ready = 'b1;
      shift_result = 'b1;
    end
    STATE_RUN_CONTINUOUS: begin
      ready = 'b1;
      if (final_run)
        next_state = STATE_RUN;
    end
    STATE_RUN: begin
      if (run_done)
        next_state = STATE_FINISH;
      count_start = 'b1;
    end
    STATE_FINISH: begin
      if (finish_done)
        next_state = STATE_FINISHWAIT;
      finished = 'b1;
      count_start = 'b1;
    end
    STATE_FINISHWAIT: begin
      next_state = STATE_SHIFT;
    end
    STATE_SHIFT: begin
      next_state = STATE_SHIFTWAIT0;
      shift_result = 1'b1;
    end
    STATE_SHIFTWAIT0: begin
      next_state = STATE_SHIFTWAIT1;
      val = 'b1;
    end
    STATE_SHIFTWAIT1: begin
      next_state = STATE_READ_VAL;
      val = 'b1;
    end
    STATE_READ_VAL: begin
      next_state = STATE_WAIT;
      produce_run = 'b1;
    end
    default: next_state = STATE_WAIT;
  endcase 
end


endmodule