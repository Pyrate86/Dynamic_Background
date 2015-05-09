#!/bin/bash

# Répertoire parent

PARENT_DIR=${HOME}/.dynbg

# Définition de l'URL à télécharger

URL='http://weather.yahooapis.com/forecastrss?w='"$1"'&u=c'

# Emplacement du XSLT
XSLT=${PARENT_DIR}/meteo.xslt
# Fichier de destination des informations
TEMP=/tmp/meteo.txt
# Emplacement de xsltproc
XSLTCMD=/usr/bin/xsltproc

w3m -dump $URL | $XSLTCMD $XSLT - > ${PARENT_DIR}/meteo.txt
WEATHER=$(w3m -dump $URL | $XSLTCMD $XSLT - | grep -i "Condition aujourd'hui" | awk -F " : " '{print $2}')
CODE=$(w3m -dump $URL | $XSLTCMD $XSLT - | grep -i "Code" | awk -F " : " '{print $2}')
VILLE=$(w3m -dump $URL | $XSLTCMD $XSLT - | grep -i "Ville" | awk -F " : " '{print $2}')

echo "${WEATHER}"  2>> ${PARENT_DIR}/out

CONDITION=${PARENT_DIR}/condition
heureL=`grep -i "levé de soleil" ${PARENT_DIR}/meteo.txt | awk -F " : " '{print $2}' | awk -F ":" '{print $1}'`
minuteL=`grep -i "levé de soleil" ${PARENT_DIR}/meteo.txt | awk -F " : " '{print $2}' | awk -F ":" '{print $2}' | awk -F " " '{print $1}'`
heureC=`grep -i "couché de soleil" ${PARENT_DIR}/meteo.txt | awk -F " : " '{print $2}' | awk -F ":" '{print $1}'`
minuteC=`grep -i "couché de soleil" ${PARENT_DIR}/meteo.txt | awk -F " : " '{print $2}' | awk -F ":" '{print $2}' | awk -F " " '{print $1}'`

temperature=`grep -i "Température" ${PARENT_DIR}/meteo.txt | awk -F " : " '{print $2}'`

let "HL = heureL"
let "ML = minuteL"
let "HC = heureC+12"
let "MC = minuteC"

let heure="10#`date +%H`"

let minute="10#`date +%M`"
HEURE="`date +%H`h`date +%M`"
DATE="`date +%d/%m/%y`"

if (( ${heure} < $HL || ${heure} > $HC )); then
    FOND=${CONDITION}/night
	TIME=${PARENT_DIR}/sunny/night.png
	LOG="Night"
elif (( ${heure} == $HL )); then
    if (( ${minute} >= $ML)); then
        FOND=${CONDITION}/dawn
        TIME=${PARENT_DIR}/sunny/dawn.png
        LOG="Dawn"
    else
        FOND=${CONDITION}/night
        TIME=${PARENT_DIR}/sunny/night.png
        LOG="Night"
    fi

elif (( ${heure}  == ($HL + 1) )); then
    if (( ${minute} < $ML )); then
        FOND=${CONDITION}/dawn
        TIME=${PARENT_DIR}/sunny/dawn.png
        LOG="Dawn"
    else
        FOND=${CONDITION}
        TIME=${PARENT_DIR}/sunny/day.png
        LOG="Day"
    fi

elif (( ${heure}  == ($HC - 1) )); then
    if (( ${minute} >= $MC )); then
        FOND=${CONDITION}/dusk
        TIME=${PARENT_DIR}/sunny/dusk.png
        LOG="Dusk"
    else
        FOND=${CONDITION}
        TIME=${PARENT_DIR}/sunny/day.png
        LOG="Day"
    fi

elif ((  ${heure} == $HC )); then
    if (( ${minute} <= $MC)); then
        FOND=${CONDITION}/dusk
        TIME=${PARENT_DIR}/sunny/dusk.png
        LOG="Dusk"
    else
        FOND=${CONDITION}/night
        TIME=${PARENT_DIR}/sunny/night.png
        LOG="Night"
    fi

else
    FOND=${CONDITION}
    TIME=${PARENT_DIR}/sunny/day.png
    LOG="Day"
fi

#Parsing du temps actuel et remplacement du fichier de fond d'écran

if echo "${WEATHER}" | grep -i -q 'partly cloudy' ; then
	composite -compose Over "${FOND}/partly_cloudy.png" "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'fair' ; then
	composite -compose Over "${FOND}/fair.png" "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'sunny' ; then
	cp "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'cloudy' ; then
	composite -compose Over "${FOND}/cloudy.png" "${TIME}" "${PARENT_DIR}/bg.png"
	
elif echo "${WEATHER}" | grep -E -i -q 'storm\|thunder' ; then
	composite -compose Over "${FOND}/storm.png" "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'snow' ; then
	if cat  "${PARENT_DIR}/actual"  | grep -i -q 'snow' ; then
        composite -compose Over "${FOND}/snow_field.png" "${TIME}" "${PARENT_DIR}/tmp.png"
	    composite -compose Over "${FOND}/snow.png" "${PARENT_DIR}/tmp.png" "${PARENT_DIR}/bg.png"
        rm "${PARENT_DIR}/tmp.png"
    else
        composite -compose Over "${FOND}/snow.png" "${TIME}" "${PARENT_DIR}/bg.png"
    fi

elif echo "${WEATHER}" | grep -i -q 'rain' ; then
	composite -compose Over "${FOND}/rain.png" "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'shower' ; then
	composite -compose Over "${FOND}/shower.png" "${TIME}" "${PARENT_DIR}/bg.png"

elif echo "${WEATHER}" | grep -i -q 'fog\|drizzle' ; then
	composite -compose Over "${FOND}/fog.png" "${TIME}" "${PARENT_DIR}/bg.png"

fi

if [ ${HL} -le 10 ]; then
    HL="0${HL}"
fi
if [ ${ML} -le 10 ]; then
    ML="0${ML}"
fi
if [ ${HC} -le 10 ]; then
    HC="0${HC}"
fi
if [ ${MC} -le 10 ]; then
    MC="0${MC}"
fi

convert -background transparent -font Celestia-Redux-Medium -pointsize 30 -kerning 5 -strokewidth 2  -fill blue -stroke black -size 100x35 -gravity SouthEast label:"${HL}h${ML}" ${PARENT_DIR}/txt.png
composite -compose Over ${PARENT_DIR}/txt.png ${PARENT_DIR}/icons/weather.png -geometry +35+5 ${PARENT_DIR}/tmp.png

convert -background transparent -font Celestia-Redux-Medium -pointsize 30 -kerning 5 -strokewidth 2  -fill blue -stroke black -size 100x35 -gravity SouthEast label:"${HC}h${MC}" ${PARENT_DIR}/txt.png
composite -compose Over ${PARENT_DIR}/txt.png ${PARENT_DIR}/tmp.png -geometry +175+5 ${PARENT_DIR}/tmp.png

convert -background transparent -font Celestia-Redux-Medium -pointsize 30 -kerning 5 -strokewidth 2  -fill blue -stroke black -size 100x35 -gravity SouthEast label:"${temperature}°C" ${PARENT_DIR}/txt.png
composite -compose Over ${PARENT_DIR}/txt.png ${PARENT_DIR}/tmp.png -geometry +315+5 ${PARENT_DIR}/txt.png

composite -compose Over ${PARENT_DIR}/txt.png ${PARENT_DIR}/bg.png -gravity SouthEast ${PARENT_DIR}/bg.png

convert -background transparent -font Celestia-Redux-Medium -pointsize 15 -kerning 5 -strokewidth 2  -fill white -stroke black -size 1024x45 -gravity SouthEast label:"${VILLE} le ${DATE} à ${HEURE} " ${PARENT_DIR}/txt.png
composite -compose Over ${PARENT_DIR}/txt.png ${PARENT_DIR}/bg.png -gravity NorthEast ${PARENT_DIR}/02.png

URL='http://l.yimg.com/a/i/us/we/52/'"${CODE}"'.gif'
convert -background transparent -resize 35x35 ${URL} ${PARENT_DIR}/tmp.png
composite -compose Over ${PARENT_DIR}/tmp.png ${PARENT_DIR}/02.png -gravity SouthEast -geometry +5+0 ${PARENT_DIR}/02.png


rm ${PARENT_DIR}/txt.png ${PARENT_DIR}/bg.png ${PARENT_DIR}/tmp.png

if [ -f ${PARENT_DIR}/log ]; then
    echo  "" >> ${PARENT_DIR}/log 2>&1
else
    echo -en "---- ${DATE} ----\nLevé : ${HL}h${ML}\nCouché : ${HC}h${MC}\n\n" >> ${PARENT_DIR}/log 2>&1
fi
echo -en "#### ${HEURE} ####\n${LOG}\n${WEATHER} (${CODE})\n${temperature} °C\n" >> ${PARENT_DIR}/log 2>&1

echo "${WEATHER}" > ${PARENT_DIR}/actual
