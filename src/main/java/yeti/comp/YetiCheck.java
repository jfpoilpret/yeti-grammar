package yeti.comp;

import java.io.*;

public class YetiCheck {
	static public void main(String[] args) {
		YetiParser parser = new YetiParser();
		for (String arg: args) {
			try {
				System.out.printf("Parsing [%s]\n", arg);
				YetiScanner lexer = new YetiScanner(new UnicodeEscapes(new FileReader(arg)));
				parser.parse(lexer);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
