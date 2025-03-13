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
 logic [game_len_width_lp-1:0] current_frame;
 ctrl_states state;

 // Output Assignments
 assign ready_o = (state == IDLE);
 assign v_o = (state == READY);
 assign update_o = (state == UPDATING);
 assign en_o = (state == UPDATING) && (current_frame < frames_i);

 // FSM Logic
 always_ff @(posedge clk_i) begin
   if (reset_i) begin
     state <= IDLE;
     current_frame <= 0;
   end
   else begin
     case (state)
       IDLE: begin
         if (v_i) begin
           state <= UPDATING; // Start the game
           current_frame <= 0;
         end
       end

       UPDATING: begin
         if (current_frame < frames_i) begin
           current_frame <= current_frame + 1; // Count frames
         end
         else begin
           state <= READY; // Game complete
         end
       end

       READY: begin
         if (yumi_i) begin
           state <= IDLE; // Handshake complete, return to IDLE
         end
       end

       default: begin
         state <= IDLE; // Default case
       end
     endcase
   end
 end

endmodule