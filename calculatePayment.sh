#!/bin/bash

printHelpMessage(){
	echo "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
}

checkNumberOfParameters(){
	if (($# < 2)); then 
		>&2 echo "Number of parameters received : $#"
		printHelpMessage
		value1=false	
	else value1=true	
	fi	
}

checkValidNumber(){
	if ! [[ ${@: -1} =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
		>&2 echo "Not a valid number : ${@: -1}" >&2
		printHelpMessage
		value2=false	
	else value2=true
	fi	
}





checkFilesExist(){
	local filesCounter=1
	local totalfiles=$#
	local notExistFilesCounter=0
	while ((totalfiles > filesCounter)); do
		if [[ ! -f "${@:$filesCounter:1}" && ! -e "${@:$filesCounter:1}" ]]; then
			>&2 echo "File does not exist : ${@:$filesCounter:1}"
			notExistFilesCounter=$((notExistFilesCounter+1))
			if [[ $notExistFilesCounter -gt 0 && $filesCounter -ge $totalfiles-1 ]]; then
				 printHelpMessage
			fi
		fi
		filesCounter=$((filesCounter+1))
	done
	if [[ $notExistFilesCounter -gt 0 ]]; then
		value3=false
	else value3=true
	fi
}



calculateBill(){
	FilesCounter=1
	totalfiles=$# 	
	while ((totalfiles > FilesCounter)); do
		thisFile=${@:$FilesCounter:1}
		while IFS= read -r line
		do
			echo "$line" | grep -Eo '[+]?[0-9]+([.][0-9]+)?'>> sumPrices.txt

		done < "$thisFile"
		let FilesCounter=FilesCounter+1
	done
	bill=`cat sumPrices.txt | grep -Eo "[0-9]+([.][0-9]+)?" | paste -sd + - | bc`
	printf "Total purchase price : %0.2f\n" $bill		
}



calculatePayment(){
	change=`echo ${@: -1} - $bill | bc`
	if [ $(echo "$change > 0" | bc) -eq 1 ]; then
		printf "Your change is %0.2f shekel\n" $change
	elif [ $(echo "$change < 0" | bc) -eq 1 ]; then
		change=`echo $bill - ${@: -1} | bc`
		printf "You need to add %0.2f shekel to pay the bill\n" $change
	else echo "Exact payment"
	fi
	rm sumPrices.txt
}

### Main Function
checkNumberOfParameters $*
if [[ "$value1" == "true" ]]; then
	checkValidNumber $*
	if [[ "$value2" == "true" ]]; then
		checkFilesExist $*
		if [[ "$value3" == "true" ]]; then
			calculateBill $*
			calculatePayment $*
		fi
	fi
else exit
fi
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		


