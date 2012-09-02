package yeti.comp;

import java.io.*;
import java.util.*;

import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

@Test
public class YetiGrammarTest {
	@Test(dataProvider = "expressions")
	public void checkSimpleExpression(String expr) throws Exception {
		System.out.printf("Parsing expr: >>> %s <<<\n", expr);
		check(new StringReader(expr));
	}
	
	@Test(dataProvider = "files")
	public void checkWholeFile(String file) throws Exception {
		System.out.printf("Parsing [%s]\n", file);
		check(new InputStreamReader(YetiGrammarTest.class.getResourceAsStream(file)));
	}
	
	@DataProvider
	public Object[][] expressions() throws Exception {
		// open resource file
		BufferedReader reader = new BufferedReader(new InputStreamReader(
			YetiGrammarTest.class.getResourceAsStream("/yeti-lines.txt")));
		//TODO
		List<Object[]> lines = new ArrayList<Object[]>();
		// read each line
		while (true) {
			String line = reader.readLine();
			if (line == null) {
				break;
			}
			if (line.indexOf("//") > -1) {
				line += "\n";
			}
			lines.add(new Object[]{line});
		}
		return lines.toArray(new Object[][]{});
	}
	
	@DataProvider
	public Object[][] files() {
		return new Object[][] {
			new Object[] {"/yeti-whole.txt"}
		};
	}

	static private void check(Reader reader) throws Exception {
		YetiParser parser = new YetiParser();
		YetiScanner lexer = new YetiScanner(new UnicodeEscapes(reader));
		parser.parse(lexer);
	}
}
