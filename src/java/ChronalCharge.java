import java.util.*;

public class ChronalCharge {
	public static void main(String[] args){
		Date startDate = new Date();
		long startTime = startDate.getTime();
		int[][] matrix = new int[300][300];
		int gsn = 8444;

		for(int i = 0; i < 300; i++){
			for(int j = 0; j < 300; j++){
				int x = i + 1;
				int y = j + 1;
				int rackID = 10 + x;
				int v = (rackID * y + gsn) * rackID;
				matrix[i][j] = (v % 1000) / 100 - 5;
			}
		}

		int xMax = 0;
		int yMax = 0;
		int sizeMax = 0;
		int powerMax = -100;

		for(int x = 0; x < 300; x++){
			for(int y = 0; y < 300; y++){
				int power = 0;
				for(int l = 0; l < 300 - x && l < 300 - y; l++){
					for(int i = 0; i < l; i++){
						power += matrix[x + i][y + l] + matrix[x + l][y + i];
					}
					power += matrix[x + l][y + l];
					if(power > powerMax){
						powerMax = power;
						xMax = x + 1;
						yMax = y + 1;
						sizeMax = (l + 1) * (l + 1);
					} 
				}
			}
		}

		System.out.println("X, Y: " + xMax + ", " + yMax + ", size: " + sizeMax);

	}
}
