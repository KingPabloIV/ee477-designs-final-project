module bsg_cgol_ctrl #(
  parameter max_game_length_p, // Maximum number of frames
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
  logic unsigned [game_len_width_lp-1:0] current_frame;

  ctrl_states state;
  ctrl_states next_state;

  logic ready_out, v_out, update_out, en_out;

  assign ready_o = ready_out;
  assign v_o = v_out;
  assign update_o = update_out;
  assign en_o = en_out;

  // Update state and counters on clock edge
  always @(posedge clk_i) begin
    if (reset_i) begin
      state <= IDLE;
      current_frame <= 0;
      max_frames <= 0;
    end else begin
      state <= next_state;
      if (state == UPDATING) begin
        current_frame <= current_frame + 1; // Increment frame counter
      end else begin
        current_frame <= 0; // Reset frame counter when not in UPDATING state
      end
      if (state == IDLE && v_i && ready_out) begin
        max_frames <= frames_i; // Capture frames_i when handshake completes
      end
    end
  end

  // Determine next state and outputs
  always_comb begin
    ready_out = 0;
    v_out = 0;
    update_out = 0;
    en_out = 0;
    next_state = state;

    case (state)
      IDLE: begin
        ready_out = 1; // Ready to accept new input
        if (v_i) begin
          update_out = 1; // Trigger update for one cycle
          next_state = UPDATING;
        end
      end

      UPDATING: begin
        en_out = 1; // Enable cell computation
        if (current_frame >= max_frames - 1) begin
          next_state = READY; // Transition to READY when frame count is complete
        end
      end

      READY: begin
        v_out = 1; // Indicate output is valid
        if (yumi_i) begin
          next_state = IDLE; // Transition to IDLE when output is acknowledged
        end
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule