package com.suyeon.checkMsg;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Handles requests for the application home page.
 */

@Service
public class CheckMsgService {
	
	private static final Logger logger = LoggerFactory.getLogger(CheckMsgService.class);
	
	public TreeMap<String, String> createGetI18n(String standardMsgfilePath, String viewName) throws FileNotFoundException {
		logger.info("createGetI18n");
		HashMap<String, String> msgMap = getMessages(standardMsgfilePath); 
		TreeMap<String, String> matched = new TreeMap<String, String>(); 
		Pattern pattern = Pattern.compile(viewName); 
		System.out.println(pattern);
		Iterator<String> itr= msgMap.keySet().iterator();  
		while(itr.hasNext()){
			String key = itr.next();  
			Matcher match = pattern.matcher(key);  
			while(match.find()){
				int idx = key.indexOf(".",11);
				String newKey = key.substring(idx+1);
				int count = newKey.split("\\.").length; 
				if(count>0){
					//하나 이상 있으면 ...
					int startidx = 0; 
					String carmelKey = newKey;   
					for(int i = 0; i<count-1 ; i++){
						int point  = carmelKey.indexOf(".",startidx); 
						StringBuilder sb = new StringBuilder(carmelKey);  
						Character c = new Character(carmelKey.charAt(point+1)); 
						if(Character.isLowerCase(c)){
							c=Character.toUpperCase(c); 
						}
						sb.setCharAt(point+1, c);
						carmelKey=sb.toString(); 
						startidx = point+1; 
					}//for

					matched.put("\""+carmelKey.replaceAll("\\.","")+"\"", "\"<s:message code='"+ key +"/>\",//"+msgMap.get(key)); 
				}else{
					matched.put("\""+newKey+"\" ","\"<s:message code='"+ key +"/>\",//"+msgMap.get(key)); 
				}

			}//while
		}//itr
		return matched; 
	}
	

	public ArrayList<String> fileMsgCheck(String filepath, ArrayList<Object> patterns){
		ArrayList<String> justlist = new ArrayList<String>(); 
		//ArrayList<String> patterns = new ArrayList<String>(); 
		justlist.add(filepath); 
		//self.getI18nself.getI18n(
		//patterns.add("self.getI18n\\(\"([^>\"']+)\""); 
		ArrayList<String> result = new ArrayList<String>(extractionMessage(justlist, patterns).keySet()); //키만 필요함. 
		Collections.sort(result); 
		return result; 
	}
	
	public HashMap<String, Object> getAllMessage(String messagefileDir) throws FileNotFoundException{
		System.out.println("--------------getfilePath: "+messagefileDir +"--------------");
		ArrayList<String> messagefilepath = getFilePath(messagefileDir); 
		HashMap<String, Object> msgResultMap = new HashMap<>();// fileName이랑 code를 추출한 map이value로 들어 있음. 

		for(int i = 0; i< messagefilepath.size(); i++){
			String fileName = messagefilepath.get(i).substring(messagefileDir.length()+1);
			//System.out.println("[진행] 파일 검사 및 추출 중: "+fileName);
			HashMap<String, String> result = getMessages(messagefilepath.get(i));
			msgResultMap.put(fileName, result);  
		}
		
		return msgResultMap; 
	}
	public HashMap<String, String> getEntireMsg(String messagefileDir) throws FileNotFoundException{
		System.out.println("--------------getfilePath: "+messagefileDir +"--------------");
		ArrayList<String> messagefilepath = getFilePath(messagefileDir); 
		HashMap<String, String> entireMsg = new HashMap<String,String>();// 전체 메시지를 하나로..

		for(int i = 0; i< messagefilepath.size(); i++){
			//System.out.println("[진행] 파일 검사 및 추출 중: "+fileName);
			HashMap<String, String> result = getMessages(messagefilepath.get(i));
			entireMsg.putAll(result);
		}
		
		return entireMsg; 
	}
	
	@SuppressWarnings("unchecked")
	public HashMap<String, Object> messageSyncCheck(HashMap<String, Object> messageMap){

		/*System.out.println("─────────────────────────────────────────────────────────────────────────────────────");
		System.out.println("검사를 위한 메세지 프로퍼티 파일 내용 추출 ");
		System.out.println("경로: "+ msgPropDir);
		System.out.println("─────────────────────────────────────────────────────────────────────────────────────");*/
		
		HashMap<String, Object> msgResultMap = messageMap; 

		HashMap<String, String> entireMsg = new HashMap<>(); 
		// 비교 시작 
		HashMap<String, Object> syncresultMap = new HashMap<>(); 
		
		Iterator<String> itr = msgResultMap.keySet().iterator(); 
		
		while(itr.hasNext()){
			Object fileName = itr.next();
			entireMsg.putAll((HashMap<String,String>) msgResultMap.get(fileName));
			System.out.println("-------------------- entireMsg <------------------"+fileName);
		}
		System.out.println("전체 메시지 수 "+ entireMsg.size());
		//System.out.println("● "+ fileName.toString() +"에 누락 된 메시지 code(key값)."); 
		itr = msgResultMap.keySet().iterator();
		while(itr.hasNext()){
			Object fileName = itr.next();
			System.out.println(fileName.toString()+"과 전체 메시지 비교 중...................");
			syncresultMap.put(fileName.toString(), sortByKey(compareTwoHmapKey(entireMsg, (HashMap<String, String>)msgResultMap.get(fileName)), true)); 
		}
		return syncresultMap; 
	}
	

	
	/**
	 * pMap1의 key가 pMap2에 있는지 check 하고 key가 없는 경우 result(hashMap)에 저장
	 * @param pMap1
	 * @param pMap2
	 * @return result(HashMap) 
	 */
	public HashMap<String, String> compareTwoHmapKey(Map<String, String> pMap1, Map<String, String> pMap2) {
		HashMap<String, String> result = new HashMap<>();
		Iterator<String> itr = pMap1.keySet().iterator(); 
		while(itr.hasNext()){
			Object code = itr.next(); 
			if(pMap2.keySet().contains(code)!=true){
				result.put(code.toString(),pMap1.get(code)); 
			}
		}
		return result;
	}
	public Map<Object, Object> mappingTwoHmap(Map<String,String> pMap1, Map<String,String> pMap2, Map<Object, Object> result){
		Iterator<String> itr = pMap1.keySet().iterator(); 
		while(itr.hasNext()){
			Object code = itr.next(); 
			String newKey = code.toString()+"\n"+pMap1.get(code); 
			if(pMap2.keySet().contains(code)==true){
				if(result.containsKey(newKey)==true){
					result.put(newKey, result.get(newKey).toString()+ pMap2.get(code).toString());
				}else{
					result.put(newKey, pMap2.get(code).toString()); 
				}
			}else{
				//System.out.println("없음"+ code.toString()+pMap1.get(code).toString());
				if(result.containsKey(newKey)==true){
					result.put(newKey, result.get(newKey).toString());
				}else{
					result.put(newKey, ""); 
				}
			}
		}
		result = sortByKey(result, true); 
		return result;
	}
	/**
	 * HashMap을 출력해 줌. 
	 * n건이 있습니다. key : value 
	 * @param hmap
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void printMap(String title , Map paramMap) {
		if(title != "" || title != null){
			System.out.println("========== " + title+ "을(를) 출력합니다.===========");
		}
		if(paramMap.size() !=0){
			System.out.println("[결과]" + paramMap.size()+"건이 있습니다.");
			Iterator<String> itr = paramMap.keySet().iterator();
			System.out.print("{ ");
			while(itr.hasNext()){
				Object key = itr.next(); 
				Object value = paramMap.get(key);  
				if(value instanceof String){
					String stringVal = (String)value; 
					System.out.println(key.toString()+ " : \"" + stringVal +"\"");
				}else if(value instanceof List){
					List list = (List)value;
					System.out.print(key.toString() + ": [");
					for(Object obj : list){
						String listVal = (String)obj;
						System.out.print("\""+ listVal +"\"");
					}
					System.out.println("]");
				}else if(value instanceof Map){
					Map mapVal = (Map)value; 
					printMap("", mapVal); 
				}else{
					System.out.println("출력이 불가능한 type");
				}
			}
			System.out.println(" }");
		}else{
			System.out.println("[결과] 결과가 없습니다. ");
		}
		System.out.println("==========================================");
	}
	/**
	 * param을 받아서, 안에 있는 file의 filepath를 
	 * arraylist에 저장하기 위해 listFilesForFolder메소드를 감싸고 있음. 
	 * @param filepath
	 * @return
	 */
	public ArrayList<String> getFilePath(String filepath) {

		return getFilePath(filepath, "");
	}
	public ArrayList<String> getFilePath(String filepath,String fileExtension) {
		ArrayList<String> filePathList = new ArrayList<>(); 
		System.out.println(filepath+"/"+filePathList.toString() +" /"+ fileExtension);
		filePathList = FilesListinFolder(new File(filepath), filePathList, fileExtension); //jsp 파일탐색
		System.out.println("[결과]"+filePathList.size()+"개의 파일이 검색되었습니다. ");
		System.out.println("　└─검색된 파일의 경로를 반환합니다.");
		return filePathList;
	}
	
	public ArrayList<String> FilesListinFolder(final File folder, ArrayList<String> filePathList, String fileExtension){		
		for(final File fileEntry : folder.listFiles()){
			if(fileEntry.isDirectory()){
				//System.out.println("----------------dir"+fileEntry.getName());
				FilesListinFolder(fileEntry, filePathList, fileExtension);
			}else{
				if(fileEntry.isFile()&&fileEntry.getName().contains(fileExtension)){
					//System.out.println(fileEntry.getName()+"/    "+fileEntry.getPath());
					filePathList.add(fileEntry.getPath()); 
				}
			}
			//end for
		}
		return filePathList;
	}//end listFilesForFolder 
	public Map<String, String> getFilePathtoMap(String filepath) throws FileNotFoundException {
		return getFilePathtoMap(filepath,"");
	}
	public Map<String, String> getFilePathtoMap(String filepath, String fileExtension) throws FileNotFoundException {
	/*	File dir = new File(filepath); 
		if(!dir.exists() || !dir.isDirectory()) { 
	         new 
	    } 
		*/
		Map<String,String> filePathMap = new HashMap<>();
		System.out.println(filepath+"/"+fileExtension);
		if(new File(filepath).exists()){
			filePathMap = FilesListinFoldertoMap(new File(filepath), filePathMap, fileExtension); //jsp 파일탐색
			System.out.println("[결과]"+filePathMap.size()+"개의 파일이 검색되었습니다. ");
			System.out.println("　└─검색된 파일의 경로를 반환합니다.");
			return filePathMap;
		}else{
			throw new FileNotFoundException(); 
		}
		
	}
	private Map<String,String> FilesListinFoldertoMap(final File folder, Map<String,String> filePathMap, String fileExtension){		
		for(final File fileEntry : folder.listFiles()){
			if(fileEntry.isDirectory()){
				//System.out.println("----------------dir"+fileEntry.getName());
				FilesListinFoldertoMap(fileEntry, filePathMap, fileExtension);
			}else{
				if(fileEntry.isFile()&&fileEntry.getName().contains(fileExtension)){
					//System.out.println(fileEntry.getName()+"/    "+fileEntry.getPath());
					filePathMap.put(fileEntry.getName(), fileEntry.getPath()); 
				}
			}
			//end for
		}
		return (Map<String, String>) filePathMap;
	}//end listFilesForFolder 
	/**
	 * messagefilepath를 파라미터로 받아서 파일을 로드해서 한줄씩 읽으면서 code와 value를 hashmap에 저장해서 리턴함.
	 * code에 중복이 있거나 value에 빈값이 있으면 알려줌. 
	 * @param messagefilepath
	 * @return messageMap(hashMap) 
	 * @throws FileNotFoundException 
	 */
	public HashMap<String, String> getMessages(String messagefilepath) throws FileNotFoundException{
		BufferedReader br = null;
		InputStreamReader isr = null; 
		FileInputStream fis = null; 
		File file = null; 
		String temp = null; 
		HashMap<String, String> messagesMap = new HashMap<>();  
		try{
			file = new File(messagefilepath); 
			fis = new FileInputStream(file);
			isr = new InputStreamReader(fis,"UTF-8"); 
			br = new BufferedReader(isr); 

			//한줄한줄 찾아보자 
			while((temp=br.readLine())!=null){
				temp = temp.trim();
				if(temp.startsWith("#")==false&&temp.length()!=0){
					String[] array= temp.split("=");
					String code=array[0].trim();
					String value=""; 

					if(array.length==1){
						value=""; 
						System.out.println("[warning]!! 메시지 코드에 대한 값이 없습니다.: " + code);

					}else{
						value=unicodeConvert(array[1]);
					}

					if(messagesMap.containsKey(code)){
						System.err.println("[warning]!! 중복 된 메시지 코드가 있습니다.: "+code+","+value);
					}
					messagesMap.put(code, value);

				}
			}

		} catch(FileNotFoundException e){
			throw new FileNotFoundException(); 
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			System.out.println("[success!]"+messagefilepath+"에서"+messagesMap.size()+"건 추출이 완료되었습니다.");
			try {
				fis.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			try {
				isr.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			try {
				br.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

		}


		return messagesMap;
	}

	private static String unicodeConvert(String str) {
		StringBuilder sb = new StringBuilder();
		char ch;
		int len = str.length();
		for (int i = 0; i < len; i++) {
			ch = str.charAt(i);
			if (ch == '\\' && str.charAt(i+1) == 'u') {
				sb.append((char) Integer.parseInt(str.substring(i+2, i+6), 16));
				i+=5;
				continue;
			}
			sb.append(ch);
		}
		return sb.toString();
	}	

	/**
	 * pattern 리스트를 받아서 파일경로리스트에 포함된 파일을 읽어들여 한줄 씩 해당 패턴에 매칭 되는 코드를 추출함.
	 * 추출된 code는 code와 함께 포함되어 있는 파일을  hashmap에 저장함. 
	 * @param basedir 
	 * @param filepath
	 * @param javaPatterns
	 * @return usingMsg(HashMap)
	 */
	public HashMap<String, String> extractionMessage(List<String> filepath, List<Object> javaPatterns){
		BufferedReader br = null;
		InputStreamReader isr = null; 
		FileInputStream fis = null; 
		File file = null; 
		String temp = null; 
		//HashMap<String, String> usingMsg = new HashMap<>(); 
		HashMap<String, String> usingMsgLine = new HashMap<>(); 
		for(Object obj: javaPatterns){
			System.out.println("[진행]"+(String)obj+"와 일치하는 code를 추출합니다. ");
			Pattern pattern = Pattern.compile(obj.toString());	
			for(int i = 0; i < filepath.size(); i++) {
				//file명 만들기 
				try{
					file = new File(filepath.get(i)); 
					fis = new FileInputStream(file);
					isr = new InputStreamReader(fis, "UTF-8"); 
					br = new BufferedReader(isr); 
					String fileName = file.getName(); 
					//한줄한줄 찾아보자 
					while((temp=br.readLine())!=null){
						Matcher match = pattern.matcher(temp.trim()); 
						while(match.find()){

							//usingMsg.put(match.group(1),fileName);
							// System.out.println(temp);
							usingMsgLine.put(match.group(1),"\t 파일명: "+fileName+"\n\t("+temp.trim()+")");
						}	
					}

				} catch(FileNotFoundException e){
					e.printStackTrace(); 
				} catch(PatternSyntaxException e){
					e.printStackTrace(); 
					throw e; 
				}catch (Exception e) {
					e.printStackTrace();
				} finally {
					try {
						fis.close();
					} catch (IOException e) {
						e.printStackTrace();
					}

					try {
						isr.close();
					} catch (IOException e) {
						e.printStackTrace();
					}

					try {
						br.close();
					} catch (IOException e) {
						e.printStackTrace();
					}

				}
			}
		}
		System.out.println("[메시지 추출 종료]");
		//간단하게 보고 싶을 경우 usingMsg를 리턴한다. 코드랑 파일명만 나옴. 
		//usingMsgLine 을 return 할 경우 코드, 파일명, 해당 line이 출력 된다. 프로퍼티파일에 안넣어도 되는것도 검출 되기때문에 귀찮아서 ...
		return usingMsgLine;
	}
	
	@SuppressWarnings({"unchecked","rawtypes"})
	public Map<Object,Object> sortByKey(final Map map, Boolean isASC){

		if(isASC){
			return new TreeMap<Object,Object>(map); 
		}else{
			TreeMap<Object,Object> tree = new TreeMap<Object,Object>(Collections.reverseOrder()); 
			tree.putAll(map);
			return tree; 
		}
		
	}
	@SuppressWarnings({"unchecked","rawtypes"})
	public Map<Object,Object> sortByValue(final Map map, Boolean isASC){
		List list = new LinkedList(map.entrySet());  
		
		Collections.sort(list, new Comparator(){

			@Override
			public int compare(Object o1, Object o2) {
				return (int) ((Comparable)((Map.Entry)(o1)).getValue()).compareTo(((Map.Entry)(o2)).getValue());
			}
			
		});
		
		if(isASC){
			Collections.reverse(list);
		}
		
		HashMap sortedHashMap = new LinkedHashMap<>();  
		for(Iterator itr = list.iterator(); itr.hasNext();){
			Map.Entry entry = (Map.Entry<Object, Object>)itr.next();  
			sortedHashMap.put(entry.getKey(), entry.getValue()); 
		}
		
		return sortedHashMap; 
	}

	/** 
	 * 메시지 파일을 수정해서 새로운 메시지 파일을 만들어 주는 서비스
	 * @param codeAndVal
	 * @param deletelist
	 * @param new fileName 
	 * @param messagefilepath
	 * @return
	 */
	
	public String createfile(HashMap<String, Object> codeAndVal, List<Object> deletelist, String folderPath, String fileName){
		
		return createfile(codeAndVal, deletelist, folderPath, fileName, fileName); 
	}
	
	public String createfile(Map<String,Object> updateMsg, List<Object> deletelist, String folderPath, String fileName, String newfileName){
		logger.info("---------------------------------------------------------------- createFile ----------------------------------");
		File file = null; 
		File temp_file = null; 
		File backupFile = null; 
		File newFile = null; 
		System.out.println( ">>>>" +folderPath + "/" + fileName + ">>>>>>>>" + newfileName);
		
		try{
			//standardFile 
			file = new File(folderPath, fileName+".properties"); 
			temp_file = new File(folderPath, "temp_"+fileName+".properties"); // 얘로 copy 할예정임. 
			
			if(fileCopy(file, temp_file)){
				System.out.println("임시파일이 생성 됨." + temp_file.getPath());
			};
			
			System.out.println("복사할 대상이 되는 파일: " +  temp_file.getName());
			
			// 새로 생성해야 하는 파일명이 이미 존재 하면 백업해야 하므로...
			if(fileName.equals(newfileName)){
				fileBackup(file); 
				
			}else{
				backupFile= new File(folderPath, newfileName+".properties"); 
				fileBackup(backupFile); 
			}
			
			newFile = new File(folderPath, newfileName+".properties");
			fileCopy(temp_file, newFile); 
			System.out.println("새로 파일이 생성되었습니다.>>>>"+newFile.getName());
			
			System.out.println("파일 수정을 시작합니다.>> ");
			
			FileInputStream fis = new FileInputStream(temp_file);
			InputStreamReader isr = new InputStreamReader(fis,"UTF-8"); 
			BufferedReader br = new BufferedReader(isr); 
			FileWriter fw = new FileWriter(newFile); 
			BufferedWriter bw = new BufferedWriter(fw); 
			String temp = null; 
			
			while((temp=br.readLine())!=null){
				System.out.println(temp);
				temp = temp.trim();
				if(temp.startsWith("#")){
					//주석처리 
					bw.write(temp);
					bw.newLine();
				}else if(temp.length()==0){
					// 빈칸일때 
					bw.newLine(); 
				}else{
					String[] array= temp.split("=");
					String code=array[0].trim();
					String value=""; 
					System.out.println(updateMsg.containsKey(code));

					if(updateMsg.containsKey(code)){
						System.out.println((String)updateMsg.get(code));
						value = unicodeConvert((String)updateMsg.get(code));
						System.out.println(value);
						temp = code + "=" + value;
						System.out.println(temp);
						logger.info("\n [eidt]" + temp);
						bw.write(temp);
						bw.newLine();
					}else if(deletelist.contains(code)){
						logger.info("\n [delete]"+ (String)code);
					}else{
						//update나 삭제 되지 않은 애들..
						bw.write(temp);
						bw.newLine();
					}
				}
				bw.flush();
				fileBackup(temp_file); 
			}
			
			try {
				fis.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			try {
				isr.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			try {
				fw.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			try {
				br.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			try{
				bw.close();
			}catch (IOException e) {
				e.printStackTrace();
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		logger.info(newFile.getName() + "파일을 생성 하였습니다. ");
		String infoText = newFile.getName()+"을 생성하였습니다."; 
		return infoText;
	}

	public boolean fileCopy(File file, File temp_file){
		System.out.println(file.getName()+">>>>"+ temp_file.getName()+"복사시작 ");
		InputStream is = null; 
		OutputStream os = null; 
		try{
			is = new FileInputStream(file); 
			os = new FileOutputStream(temp_file);  
			byte[] buffer = new byte[1024];
	        int length;
	        
	        while ((length = is.read(buffer)) > 0) {
	            os.write(buffer, 0, length);
	        }
	        
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			try {
				os.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			System.out.println(file.getName()+">>>>"+ temp_file.getName()+"복사끝");
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean fileBackup(File file){
		String folderPath = file.getParent();  
		try{
			File dir = new File(folderPath+"/bak");
			if(file.exists()){
				System.out.println("새로 생성할 파일명이 이미 있음.");
				//bakupfolder가 있는지 확인 
				if(!dir.exists() || !dir.isDirectory()) { 
					dir.mkdirs(); 
			    } 
				int p = (file.getName()).lastIndexOf("."); 
				String backupFileName =  file.getName().substring(0,p); 
				 
				File backupFile;
				
				do{
					backupFileName = "bak_" +backupFileName; 
					backupFile = new File(dir, backupFileName+".properties"); 

				}while(backupFile.exists()); 
				
				System.out.print(">>>> 백업된 파일 경로  :  "+ backupFile.getPath());
				boolean isMoved = file.renameTo(backupFile); 
				System.out.println(" ////// 백업파일 이동 성공 : " + isMoved);
				System.out.println("!!!!!!" +  file.getName()+ "을" + backupFile.getName()+" 파일로 백업함."); 
			}
			return true;
		}catch (Exception e) {
			return false; 
		}
		
	}

	public Map<String, Object> jsonToMap(JSONObject json) throws JSONException {
	    Map<String, Object> retMap = new HashMap<String, Object>();

	    if(json != JSONObject.NULL) {
	        retMap = toMap(json);
	    }
	    return retMap;
	}

	public Map<String, Object> toMap(JSONObject object) throws JSONException {
	    Map<String, Object> map = new HashMap<String, Object>();

	    Iterator<String> keysItr = object.keys();
	    while(keysItr.hasNext()) {
	        String key = keysItr.next();
	        Object value = object.get(key);

	        if(value instanceof JSONArray) {
	            value = toList((JSONArray) value);
	        }

	        else if(value instanceof JSONObject) {
	            value = toMap((JSONObject) value);
	        }
	        map.put(key, value);
	    }
	    return map;
	}

	public List<Object> toList(JSONArray array) throws JSONException {
	    List<Object> list = new ArrayList<Object>();
	    for(int i = 0; i < array.length(); i++) {
	        Object value = array.get(i);
	        if(value instanceof JSONArray) {
	            value = toList((JSONArray) value);
	        }

	        else if(value instanceof JSONObject) {
	            value = toMap((JSONObject) value);
	        }
	        list.add(value);
	    }
	    return list;
	}
}
