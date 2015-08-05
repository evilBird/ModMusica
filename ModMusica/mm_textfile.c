/* Copyright (c) 1997-1999 Miller Puckette and others.
* For information on usage and redistribution, and for a DISCLAIMER OF ALL
* WARRANTIES, see the file, "LICENSE.txt," in this distribution.  */

#include "m_pd.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define LINESZ                      1024
#define MIN_TEMPO                   40
#define MAX_TEMPO                   180
#define NUM_SEQS                    7
#define DEFAULT_MEASURES            1
#define DEFAULT_BEATS               4
#define DEFAULT_DIVS                2
#define DEFAULT_SWING               0
#define HEADER_LENGTH               6
#define MAX_LENGTH                  1024


#define MEASURES_SYMBOL             "measures"
#define BEATS_SYMBOL                "beats"
#define DIVISIONS_SYMBOL            "divisions"
#define SWING_SYMBOL                "swing"
#define MINTEMPO_SYMBOL             "minTempo"
#define MAXTEMPO_SYMBOL             "maxTempo"
#define LENGTH_SYMBOL               "length"
#define NAME_SYMBOL                 "name"
#define SEQUENCE_SYMBOL             "sequence"


typedef struct _mm_textfile
{
    t_object  x_obj;
    int measures;
    int beats;
    int divisions;
    int swing;
    int minTempo;
    int maxTempo;
    int length;
    int **sequences;
    char name[500];
    t_symbol *myDirectory;
    t_outlet *print_out;
    
}t_mm_textfile;

static t_class *mm_textfile_class;

int mm_textfile_get_length(t_mm_textfile *x)
{
    int measures = x->measures;
    int beats = x->beats;
    int divisions = x->divisions;
    
    return (measures * beats * divisions);
}

static void mm_textfile_print_sequences(t_mm_textfile *x)
{
    int length = x->length;
    for (int j = 0; j < length; j++) {
        post("%d, %d, %d, %d, %d, %d, %d",x->sequences[0][j],x->sequences[1][j],x->sequences[2][j],x->sequences[3][j],x->sequences[4][j],x->sequences[5][j],x->sequences[6][j]);
    }
}

static void mm_textfile_free_sequences(t_mm_textfile *x)
{
    int numSeqs = NUM_SEQS;
    int length = MAX_LENGTH;
    for (int i = 0; i < numSeqs; i++) {
        freebytes(x->sequences[i],sizeof(int)*length);
    }
    
    freebytes(&x->sequences,sizeof(int*)*numSeqs);
}

static void mm_textfile_alloc_sequences(t_mm_textfile *x)
{
    int numSeqs = NUM_SEQS;
    int length = MAX_LENGTH;
    x->sequences = getbytes(sizeof(int*)*numSeqs);
    for (int i = 0; i < numSeqs; i++) {
        x->sequences[i] = getbytes(sizeof(int)*length);
        for (int j = 0; j < length; j++) {
            x->sequences[i][j] = 0;
        }
    }
    
}

static void mm_textfile_clear_sequences(t_mm_textfile *x)
{
    post("clear sequences");
    int numSeqs = NUM_SEQS;
    int length = MAX_LENGTH;//x->length;
    for (int i = 0; i < numSeqs; i++) {
        for (int j = 0; j < length; j++) {
            x->sequences[i][j] = 0;
        }
    }
}

static void mm_textfile_clear_header(t_mm_textfile *x)
{
    post("clear header");
    x->measures = DEFAULT_MEASURES;
    x->beats = DEFAULT_BEATS;
    x->divisions = DEFAULT_DIVS;
    x->swing = DEFAULT_SWING;
    x->minTempo = MIN_TEMPO;
    x->maxTempo = MAX_TEMPO;
    x->length = mm_textfile_get_length(x);
}

static void mm_textfile_update_length(t_mm_textfile *x)
{
    x->length = mm_textfile_get_length(x);
}

static void mm_textfile_clear(t_mm_textfile *x)
{
    post("clear");
    mm_textfile_clear_header(x);
    mm_textfile_clear_sequences(x);
}

static void mm_textfile_print_header(t_mm_textfile *x)
{
    post("%s %s",NAME_SYMBOL,x->name);
    post("%s %d",LENGTH_SYMBOL,x->length);
    post("%s %d",MEASURES_SYMBOL,x->measures);
    post("%s %d",BEATS_SYMBOL,x->beats);
    post("%s %d",DIVISIONS_SYMBOL,x->divisions);
    post("%s %d",SWING_SYMBOL,x->swing);
    post("%s %d",MINTEMPO_SYMBOL,x->minTempo);
    post("%s %d",MAXTEMPO_SYMBOL,x->maxTempo);
    
    t_atom metadata[2];
    metadata[0].a_type = A_SYMBOL;
    metadata[1].a_type = A_FLOAT;
    
    SETSYMBOL(&metadata[0],gensym("length"));
    SETFLOAT(&metadata[1],x->length);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("measures"));
    SETFLOAT(&metadata[1],x->measures);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("beats"));
    SETFLOAT(&metadata[1],x->beats);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("divisions"));
    SETFLOAT(&metadata[1],x->divisions);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("minTempo"));
    SETFLOAT(&metadata[1],x->minTempo);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("maxTempo"));
    SETFLOAT(&metadata[1],x->maxTempo);
    outlet_list(x->print_out,&s_list,2,metadata);
    SETSYMBOL(&metadata[0],gensym("swing"));
    SETFLOAT(&metadata[1],x->swing);
    outlet_list(x->print_out,&s_list,2,metadata);
}


static void mm_textfile_print(t_mm_textfile *x)
{
    mm_textfile_print_header(x);
    mm_textfile_print_sequences(x);
}

static void mm_textfile_write_header(t_mm_textfile *x,char output[])
{
    char measures_string[50];
    
    sprintf(measures_string,"%s,%d,,,,,","measures",x->measures);
    strcpy(output,measures_string);
    
    char beats_string[50];
    sprintf(beats_string,"\n%s,%d,,,,,","beats",x->beats);
    strcat(output,beats_string);
    
    char divs_string[50];
    sprintf(divs_string,"\n%s,%d,,,,,","divisions",x->divisions);
    strcat(output,divs_string);
    
    char min_tempo_string[50];
    sprintf(min_tempo_string,"\n%s,%d,,,,,","minTempo",x->minTempo);
    strcat(output,min_tempo_string);
    
    char max_tempo_string[50];
    sprintf(max_tempo_string,"\n%s,%d,,,,,","maxTempo",x->maxTempo);
    strcat(output,max_tempo_string);
    
    char swing_string[50];
    sprintf(swing_string,"\n%s,%d,,,,,","swing",x->swing);
    strcat(output,swing_string);
    
}

static void mm_textfile_write_sequences(t_mm_textfile *x,char output[])
{
    
    char body[100000];
    int length = x->length;
    
    for (int i = 0; i < length; i ++)
    {
        char newline[50];
        sprintf(newline,"\n");
        if (!i) {
            strcpy(body,newline);
        }else{
            strcat(body,newline);
        }
        for (int j = 0; j < NUM_SEQS; j++){
            int val = x->sequences[j][i];
            char myString[50];
            sprintf(myString,"%d,",val);
            strcat(body,myString);
        }
    }
    
    strcat(output,body);
    
}

void mm_textfile_free(t_mm_textfile *x)
{
    post("free");
    mm_textfile_free_sequences(x);
}

void mm_textfile_measures(t_mm_textfile *x, t_float f, t_float glob)
{
    x->measures = (int)f;
    post("measures: %d",x->measures);
    mm_textfile_update_length(x);
}

void mm_textfile_beats(t_mm_textfile *x, t_float f, t_float glob)
{
    x->beats = (int)f;
    post("beats: %d",x->beats);
    mm_textfile_update_length(x);
}

void mm_textfile_divisions(t_mm_textfile *x, t_float f, t_float glob)
{
    x->divisions = (int)f;
    post("divisions: %d",x->divisions);
    mm_textfile_update_length(x);
}

void mm_textfile_swing(t_mm_textfile *x, t_float f, t_float glob)
{
    x->swing = (int)f;
    post("swing: %d",x->swing);
    mm_textfile_update_length(x);
}

void mm_textfile_step(t_mm_textfile *x, t_symbol *s, int argc, t_atom *argv)
{
    t_int mySeq = atom_getintarg(0,argc,argv);
    int seq = (int)mySeq;
    if (seq >= x->length) {
        post("ERROR setting step in seq %d: index exceeds array length %d",seq,x->length);
    }
    
    t_int myStep = atom_getintarg(1,argc,argv);
    int step = (int)myStep;
    
    if (step >= x->length) {
        post("ERROR setting step %d: index exceeds array length %d",step,x->length);
    }
    
    t_int myVal = atom_getintarg(2,argc,argv);
    int val = (int)myVal;
    post("set sequence %d step %d to value %d",seq,step,val);
    
    x->sequences[seq][step] = val;
    
}

void mm_textfile_sequence(t_mm_textfile *x, t_symbol *s, int argc, t_atom *argv)
{
    t_int myInt = atom_getintarg(0,argc,argv);
    int seq = (int)myInt;
    post("set sequence %d",seq);
    int length = x->length;
    
    for (int i = 1; i < (length + 1); i++) {
        int idx = i-1;
        t_int myVal = atom_getintarg(0,argc,argv);
        x->sequences[seq][idx] = (int)myVal;
    }
}

void mm_textfile_name(t_mm_textfile *x, t_symbol *s)
{
    post("textfile name %s",s->s_name);
    strcpy(x->name,s->s_name);
}

void mm_textfile_write(t_mm_textfile *x)
{
    char output[1000000];
    mm_textfile_write_header(x,output);
    mm_textfile_write_sequences(x,output);
    
    char filepath[500];
    strcpy(filepath,x->myDirectory->s_name);
    strcat(filepath,"/");
    strcat(filepath,x->name);
    strcat(filepath,".csv");
    
    FILE *fp = fopen(filepath, "ab");
    
    if (fp != NULL)
    {
        post("saved %s to path %s",x->name,filepath);
        fputs(output, fp);
        fclose(fp);
    }else{
        post("file path is null");
    }
}

void parse_line(char aLine[],int result[],int num)
{
    char *token, *string, *tofree;
    tofree = string = strdup(aLine);
    int idx = 0;
    while ((token = strsep(&string, ",")) != NULL && num > 0)
    {
        int val = 0;
        if (strlen(token)) {
            sscanf(token,"%d",&val);
        }
        
        result[idx] = val;
        num--;
        idx++;
    }
    
    free(tofree);
}

void mm_textfile_read_header(t_mm_textfile *x, FILE *file)
{
    char aLine[LINESZ];
    
    int measures = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"measures, %d",&measures);
    x->measures = measures;

    int beats = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"beats, %d",&beats);
    x->beats = beats;

    int divisions = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"divisions, %d",&divisions);
    x->divisions = divisions;

    int minTempo = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"minTempo, %d",&minTempo);
    x->minTempo = minTempo;

    int maxTempo = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"maxTempo, %d",&maxTempo);
    x->maxTempo = maxTempo;

    int swing = 0;
    fgets (aLine, LINESZ, file);
    sscanf(aLine,"swing, %d",&swing);
    x->swing = swing;
    
    int length = (measures * beats * divisions);
    x->length = length;
}

void mm_textfile_read(t_mm_textfile *x, t_symbol *s)
{
    FILE *file = fopen(s->s_name, "r");
    if (file == NULL) {
        post("couldn't open csv file");
        return;
    }
    post("reading text file at path: %s",s->s_name);

    mm_textfile_read_header(x,file);
    mm_textfile_print_header(x);
    mm_textfile_update_length(x);
    //Create arrays to store scanned values
    
    int line = 0;
    int seq_len = (x->length+2);
    
    t_atom seq0[seq_len];
    t_atom seq1[seq_len];
    t_atom seq2[seq_len];
    t_atom seq3[seq_len];
    t_atom seq4[seq_len];
    t_atom seq5[seq_len];
    t_atom seq6[seq_len];
    
    seq0[line].a_type = A_SYMBOL;
    seq1[line].a_type = A_SYMBOL;
    seq2[line].a_type = A_SYMBOL;
    seq3[line].a_type = A_SYMBOL;
    seq4[line].a_type = A_SYMBOL;
    seq5[line].a_type = A_SYMBOL;
    seq6[line].a_type = A_SYMBOL;
    
    SETSYMBOL(&seq0[line],gensym("sequence"));
    SETSYMBOL(&seq1[line],gensym("sequence"));
    SETSYMBOL(&seq2[line],gensym("sequence"));
    SETSYMBOL(&seq3[line],gensym("sequence"));
    SETSYMBOL(&seq4[line],gensym("sequence"));
    SETSYMBOL(&seq5[line],gensym("sequence"));
    SETSYMBOL(&seq6[line],gensym("sequence"));
    
    line++;
    
    seq0[line].a_type = A_FLOAT;
    seq1[line].a_type = A_FLOAT;
    seq2[line].a_type = A_FLOAT;
    seq3[line].a_type = A_FLOAT;
    seq4[line].a_type = A_FLOAT;
    seq5[line].a_type = A_FLOAT;
    seq6[line].a_type = A_FLOAT;
    
    SETFLOAT(&seq0[line],0);
    SETFLOAT(&seq1[line],1);
    SETFLOAT(&seq2[line],2);
    SETFLOAT(&seq3[line],3);
    SETFLOAT(&seq4[line],4);
    SETFLOAT(&seq5[line],5);
    SETFLOAT(&seq6[line],6);
    
    line++;
    
    char aLine[LINESZ];
    
    while (fgets (aLine, LINESZ, file)) {
        /* Process buff here. */
        int values[NUM_SEQS];
        parse_line(aLine,values,NUM_SEQS);
        
        seq0[line].a_type = A_FLOAT;
        seq1[line].a_type = A_FLOAT;
        seq2[line].a_type = A_FLOAT;
        seq3[line].a_type = A_FLOAT;
        seq4[line].a_type = A_FLOAT;
        seq5[line].a_type = A_FLOAT;
        seq6[line].a_type = A_FLOAT;
        
        SETFLOAT(&seq0[line],values[0]);
        SETFLOAT(&seq1[line],values[1]);
        SETFLOAT(&seq2[line],values[2]);
        SETFLOAT(&seq3[line],values[3]);
        SETFLOAT(&seq4[line],values[4]);
        SETFLOAT(&seq5[line],values[5]);
        SETFLOAT(&seq6[line],values[6]);
        line++;
    }
    
    //mm_textfile_alloc_sequences(x);
    //mm_textfile_clear_sequences(x);
    
    for (int i = 2; i < seq_len; i++) {
        t_int v;
        int idx = (i - 2);
        v = atom_getintarg(i,seq_len,seq0);
        //post("element (0, %d) = %d",idx,v);
        x->sequences[0][idx] = (int)v;

        v = atom_getintarg(i,seq_len,seq1);
        //post("element (1, %d) = %d",idx,v);
        x->sequences[1][idx] = (int)v;

        v = atom_getintarg(i,seq_len,seq2);
        //post("element (2, %d) = %d",idx,v);
        x->sequences[2][idx] = (int)v;
        
        v = atom_getintarg(i,seq_len,seq3);
        //post("element (3, %d) = %d",idx,v);
        x->sequences[3][idx] = (int)v;
        
        v = atom_getintarg(i,seq_len,seq4);
        //post("element (4, %d) = %d",idx,v);
        x->sequences[4][idx] = (int)v;
        
        v = atom_getintarg(i,seq_len,seq5);
        //post("element (5, %d) = %d",idx,v);
        x->sequences[5][idx] = (int)v;
        
        v = atom_getintarg(i,seq_len,seq6);
        //post("element (6, %d) = %d",idx,v);
        x->sequences[6][idx] = (int)v;

    }
    
    fclose(file);
    
    outlet_list(x->print_out,&s_list,seq_len,seq0);
    outlet_list(x->print_out,&s_list,seq_len,seq1);
    outlet_list(x->print_out,&s_list,seq_len,seq2);
    outlet_list(x->print_out,&s_list,seq_len,seq3);
    outlet_list(x->print_out,&s_list,seq_len,seq4);
    outlet_list(x->print_out,&s_list,seq_len,seq5);
    outlet_list(x->print_out,&s_list,seq_len,seq6);
}

void *mm_textfile_new(t_symbol *s, int argc, t_atom *argv)
{
    t_mm_textfile *x = (t_mm_textfile *)pd_new(mm_textfile_class);
    x->myDirectory = canvas_getcurrentdir();
    x->print_out = outlet_new(&x->x_obj, &s_list);
    x->measures = DEFAULT_MEASURES;
    x->beats = DEFAULT_BEATS;
    x->divisions = DEFAULT_DIVS;
    x->swing = DEFAULT_SWING;
    x->minTempo = MIN_TEMPO;
    x->maxTempo = MAX_TEMPO;
    x->length = (DEFAULT_MEASURES * DEFAULT_BEATS * DEFAULT_DIVS);
    mm_textfile_alloc_sequences(x);
    
    return (void *)x;
}

void mm_textfile_setup(void)
{
    mm_textfile_class = class_new(gensym("mm_textfile"), (t_newmethod)mm_textfile_new,
        (t_method)mm_textfile_free, sizeof(t_mm_textfile), 0, 0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_clear, gensym("clear"), 0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_measures, gensym("measures"),A_FLOAT,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_beats, gensym("beats"),A_FLOAT,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_divisions, gensym("divisions"),A_FLOAT,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_swing, gensym("swing"),A_FLOAT,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_sequence, gensym("sequence"),A_GIMME,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_name, gensym("name"), A_DEFSYMBOL, 0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_write, gensym("write"),0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_read, gensym("read"),A_DEFSYMBOL,0);
    class_addmethod(mm_textfile_class, (t_method)mm_textfile_print, gensym("print"),A_DEFSYMBOL,0);
}

