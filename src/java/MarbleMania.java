import java.util.*;
public class MarbleMania {
	public static int noOfPlayers;
	public static int lastMarble;


	public static void main(String[] args){
		Date date1 = new Date();
		long time1 = date1.getTime();
		noOfPlayers = 413; // TO BE MODIFIED
		lastMarble = 7108200; // TO BE MODIFIED
		System.out.println(process());
		Date date2 = new Date();
		long time2 = date2.getTime();
		System.out.println("Process took " + (time2 - time1) + " milliseconds" );
	}

	public static long process(){
		Node marbles = new Node(0); // include marble 0
		marbles.next = marbles;
		marbles.prev = marbles;
		Map<Integer, Long> playerScore = new HashMap<Integer, Long>();
		int player = 2;

		for(int marble = 1; marble <= lastMarble; marble++){
			if(marble % 23 == 0){
				for(int i = 0; i < 7; i++){
					marbles = marbles.prev;
				}
				long scoreValue = playerScore.get(player) == null ? Long.valueOf(marbles.value + marble) : Long.valueOf(marbles.value + marble + playerScore.get(player));
				playerScore.put(player, scoreValue);
				marbles = marbles.remove();
			} else {
				marbles = marbles.next.append(marble);
			}

			player = player == noOfPlayers ? 1 : player + 1;
		}

		long maxScore = 0L;
		for(long s : playerScore.values()){
			maxScore = s > maxScore ? s : maxScore;
		}
		return maxScore;
	}

	// doubly linked list
	static class Node{
		int value;
		Node prev;
		Node next;

		public Node(int value){ this.value = value; }

		Node append(int value){
			Node newNode = new Node(value);
			Node oldNext = this.next;
			this.next = newNode;
			newNode.next = oldNext;
			newNode.prev = this;
			oldNext.prev = newNode;
			return newNode;
		}

		Node remove(){
			Node next = this.next;
			Node prev = this.prev;
			prev.next = next;
			next.prev = prev;
			return next;
		}
	}
}