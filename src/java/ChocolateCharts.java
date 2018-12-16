import java.util.*;

public class ChocolateCharts{
	public static void main(String[] args){
		int n = 1;

		List<Integer> receipts = new ArrayList<Integer>();
		receipts.add(3);
		receipts.add(7);

		int elf1Index = 0;
		int elf2Index = 1;

		List<Integer> pattern = new ArrayList<Integer>();

		pattern.add(7);pattern.add(6);pattern.add(5);pattern.add(0);
		pattern.add(7);pattern.add(1);

		/*pattern.add(5);pattern.add(1);pattern.add(5);pattern.add(8);
		pattern.add(9);*/

		int p = 0;

		boolean flag = true;

		while(flag){
			int elf1Value = receipts.get(elf1Index);
			int elf2Value = receipts.get(elf2Index);

			if(elf1Value + elf2Value < 10){
				receipts.add(elf1Value + elf2Value);
				p = checkPattern(elf1Value + elf2Value, pattern, p);
				System.out.print(elf1Value + elf2Value);
				elf1Index = ((elf1Value + 1) % receipts.size() + elf1Index) % receipts.size();
				elf2Index = ((elf2Value + 1) % receipts.size() + elf2Index) % receipts.size();
			} else {
				receipts.add((elf1Value + elf2Value) / 10);
				p = checkPattern((elf1Value + elf2Value) / 10, pattern, p);
				receipts.add((elf1Value + elf2Value) % 10);
				System.out.print((elf1Value + elf2Value) / 10 + "" + (elf1Value + elf2Value) % 10);
				if(p != 6){
					p = checkPattern((elf1Value + elf2Value) % 10, pattern, p);
				}else{
					System.out.println("");
					System.out.println(receipts.size() - p - 1);
				}
				elf1Index = ((elf1Value + 1) % receipts.size() + elf1Index) % receipts.size();
				elf2Index = ((elf2Value + 1) % receipts.size() + elf2Index) % receipts.size();
			}

			if(p == 6){
				flag = false;
				System.out.println("");
				System.out.println(receipts.size() - p);
			}
		}

		StringBuilder s = new StringBuilder();
		for(int i = 0; i < 10; i++){
			s.append(receipts.get(n + i));
		}

		System.out.println(s.toString());
	}

	public static int checkPattern(int v, List<Integer> pattern, int i){
		if(pattern.get(i) == v){
			System.out.println(v);
			return i+1;
		}else{
			return pattern.get(0) == v ? 1 : 0;
		}
	}
}
