module main(linhas, colunas, btn, sw, clk, led);
	
	localparam IN_MENU = 2'b00;
	localparam RUNNING = 2'b01;
	localparam PAUSED = 2'b10;
	localparam FINISHED = 2'b11;

	localparam CALL_ME_BABY = 2'b00;
	localparam CAN_I_TRY_SOMETHING_DIFFERENT = 2'b01;
	localparam HARD = 2'b10;
	localparam I_LOST_MY_LIFE = 2'b11;

	input [11:0] btn;
	input [3:0] sw;
	input clk;
	output [4:0] colunas;
	output [7:0] linhas;
	output [3:0] led;
	
	wire clk_05ms, clk_60, clk_120, clk_30, clk_15, clk_3, clk_4;
	wire key1, key2, key3;

	wire inc_x, rst_y;
	
	wire [2:0] bol_pos_x, bol_pos_y;
	wire sentido;
	wire rst_count;
	wire clk_to_game;
	
	wire [4:0] jogador_pos;
	wire [7:0] pos_y;
	
	wire [2:0] pos_jogador;
	wire rst;
	wire [7:0] linha0, linha1, linha2, linha3, linha4;
	wire [7:0] line_bol_player;
	wire rst_player, colision_p_b, player_lost;
	reg start;


	reg [1:0] game_state;
	reg [1:0] game_dificult;
	reg [6:0] points;
	reg game_speed;
	reg on_running_game;

	assign clk_to_game = game_speed & on_running_game;

	dbouncer db1(btn[0], clk_120, key1, rst);
	dbouncer db2(btn[1], clk, key2, rst);
	dbouncer db3(btn[2], clk, key3, rst);
	
	
	assign rst = sw[3];
	
	//podemos alterar depois
	divisor_de_frequencia(clk, clk_05ms, clk_60, clk_120, clk_30, clk_15, clk_3, clk_4);
	
	count_3b counter_jogador(key3, key2, clk_to_game, rst, pos_jogador);
	
	assign rst_player = pos_jogador[2] & !pos_jogador[1] & pos_jogador[0] | pos_jogador[2] & pos_jogador[1] & pos_jogador[0];
	
	assign sentido = (pos_y == 8'b11111110) ? 1'b1: ((pos_y == 8'b10111111) ? 1'b0:sentido);
	
	//define como sera a linha que estiver a bolinha e o jogador
	assign line_bol_player = (bol_pos_x == pos_jogador) ? {1'b0, pos_y[6:0]}:pos_y;

	//faz o deslocamento da bola durante a partida
	shift_register_7b sh_bolinha(sentido, clk_to_game, rst, key1, pos_y);
	
	//define o que ira aparecer em cada linha (nem sei como eh que isso ainda funciona)
	assign linha0 = (bol_pos_x == 3'b000 & pos_jogador == 3'b000) ? line_bol_player:(pos_jogador == 3'b000 ? 8'b01111111:8'b11111111);
	assign linha1 = (bol_pos_x == 3'b001 & pos_jogador == 3'b001) ? line_bol_player:(pos_jogador == 3'b001 ? 8'b01111111:8'b11111111);
	assign linha2 = (bol_pos_x == 3'b010 & pos_jogador == 3'b010) ? line_bol_player:(pos_jogador == 3'b010 ? 8'b01111111:8'b11111111);
	assign linha3 = (bol_pos_x == 3'b011 & pos_jogador == 3'b011) ? line_bol_player:(pos_jogador == 3'b011 ? 8'b01111111:8'b11111111);
	assign linha4 = (bol_pos_x == 3'b100 & pos_jogador == 3'b100) ? line_bol_player:(pos_jogador == 3'b100 ? 8'b01111111:8'b11111111);
	
	assign inc_x = (bol_pos_x == 3'b100) ? 1'b0: (bol_pos_x == 3'b000 ? 1'b1:inc_x);
	
	//reset do eixo y da bola
	assign rst_y = bol_pos_y[2] & !bol_pos_y[1] & bol_pos_y[0];
	
	//contador da posicao da bola
	count_3b bol_counter_x(inc_x, !inc_x, clk_to_game, rst, bol_pos_x);
	
	//varredura da matriz de leds
	matriz matrix(clk_120, rst, linha0, linha1, linha2, linha3, linha4, linhas, colunas);
	
	assign colision_p_b = (!pos_y[6]) ? (bol_pos_x == pos_jogador) ? 1'b1:1'b0:1'b0;
	assign player_lost = (!pos_y[6]) ? ((bol_pos_x != pos_jogador) ? 1'b1:1'b0):1'b0;

	
	always @(posedge clk) begin
		case (game_state)
			IN_MENU: begin
				on_running_game <= 1'b0;
				//isso aqui faz iniciar o jogo e definir a dificuldade
				if (sw[0]) begin
					game_state <= RUNNING;
					start <= 1'b1;
					on_running_game <= 1'b1;
				end else if (key1) begin
					game_dificult <= game_dificult + 1;
				end else if (key2) begin
					game_dificult <= game_dificult - 1;
				end

				//define a velocidade do jogo com base na escolhida
				if (game_dificult == CALL_ME_BABY) begin
					game_speed <= clk_05ms;
				end else if (game_dificult == CAN_I_TRY_SOMETHING_DIFFERENT) begin
					game_speed <= clk_15;
				end else if (game_dificult == HARD) begin
					game_speed <= clk_30;
				end else if (game_dificult == I_LOST_MY_LIFE) begin
					game_speed <= clk_4;	//se tiver muito rapido mudar para clk_3
				end
			end
			RUNNING: begin
				start <=1'b0;
				on_running_game <= 1'b1;
				if(player_lost) begin
					on_running_game <= 1'b0;
					game_state <= FINISHED;
				end else if (colision_p_b ) begin
					points <= points + 1;
				end
				if (key1 & !player_lost) begin
					on_running_game <= 1'b0;
					game_state <= PAUSED;
				end
			end
			PAUSED: begin
				on_running_game <= 1'b0;
				if (key1) begin
					on_running_game <= 1'b1;
					game_state <= RUNNING;
				end
			end
			FINISHED: begin
				on_running_game <= 1'b0;
				if (key1) begin
					game_state <= IN_MENU;
				end
			end
			default: 
		endcase
	end
	
endmodule