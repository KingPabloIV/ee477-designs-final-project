module bsg_cgol_ctrl #(
  parameter max_game_length_p, // Corrected parameter declaration
  localparam game_len_width_lp = `BSG_SAFE_CLOG2(max_game_length_p + 1)
) (
  input  clk_i,
  input  reset_i,
  input  en_i,

  // Input Data Channel
  input  [game_len_width_lp-1:0] frames_i,
  input  v_i,
  output ready_o,

  // Output Data Channel
  input  yumi_i,
  output v_o,

  // Cell Array
  output update_o,
  output en_o
);

 // State Enumeration
 typedef enum logic [1:0] {
   IDLE,
   UPDATING,
   READY
 } ctrl_states;

 // Internal Signals
 logic unsigned [game_len_width_lp-1:0] max_frames;
 logic unsigned [game_len_width_lp-1:0] next_frame;
 logic unsigned [game_len_width_lp-1:0] current_frame;


 ctrl_states state;
 ctrl_states next_state;

logic ready_out, v_out, update_out, en_out;

assign ready_o = ready_out;
assign v_o = v_out;
assign update_o = update_out;
assign en_o = en_out;


  // Output Assignments

  always @(posedge clk_i) begin
    state <= reset_i ? IDLE : next_state;
    current_frame <= reset_i ? 0 : next_frame;
    // if (reset_i) begin
    //   ready_o <= 0;
    //   v_o <= 0;
    //   update_o <= 0;
    //   en_o <= 0;
    // end
    // else begin
    //   ready_o <= ready_out;
    //   v_o <= v_out;
    //   update_o <= update_out;
    //   en_o <= en_out;
    // end
  end

  always_comb begin
    ready_out = 0;
    v_out = 0;
    update_out = 0;
    en_out = 0;
    next_frame = 0;
    case (state)
      IDLE:  begin
        if (v_i == 1) begin
          update_out = 1;
          next_state = UPDATING;
        end else begin
          ready_out = 1;
          next_state = IDLE;
        end
      end

      UPDATING: begin
        if (current_frame < max_frames) begin
          en_out = 1;
          next_frame = current_frame + 1;
          next_state = UPDATING;
        end else begin
          v_out = 1;
          next_state = READY;
        end
      end

      READY: begin
        if (yumi_i == 1) begin
          next_state = IDLE;
        end else begin
          v_out = 1;
          next_state = READY;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end
endmodule