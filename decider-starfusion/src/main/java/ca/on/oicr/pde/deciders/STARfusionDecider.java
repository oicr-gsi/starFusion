package ca.on.oicr.pde.deciders;


import java.util.*;
import net.sourceforge.seqware.common.hibernate.FindAllTheFiles;
import net.sourceforge.seqware.common.module.FileMetadata;
import net.sourceforge.seqware.common.module.ReturnValue;
import net.sourceforge.seqware.common.module.ReturnValue.ExitStatus;
import net.sourceforge.seqware.common.util.Log;

/**
 *
 * @author alka
 */
public class STARfusionDecider extends OicrDecider {

    private String starfusionMemory = "64";

    private Set<String> allowedTemplateTypes;
    private String queue = "";
    private String templateType = "WT";
    private String inputRead1Fastq;
    private String inputRead2Fastq;
    private String externalName;
    private ReadGroupData readGroupDataForWorkflowRun;
    private String currentTtype;

    public STARfusionDecider() {
        super();
        parser.accepts("ini-file", "Optional: the location of the INI file.").withRequiredArg();

        //starfusion
        parser.accepts("starfusion-mem", "Optional: STAR allocated memory Gb, default is 64.").withRequiredArg();

        //RG parameters
        parser.accepts("template-type", "Optional: limit the run to only specified template type(s) (comma separated list).").withRequiredArg();
        parser.accepts("queue", "Optional: Set the queue (Default: not set)").withRequiredArg();
    }

    @Override
    public ReturnValue init() {
        Log.debug("INIT");
        this.setMetaType(Arrays.asList("chemical/seq-na-fastq-gzip"));
        this.setHeadersToGroupBy(Arrays.asList(FindAllTheFiles.Header.IUS_SWA));

        //allows anything defined on the command line to override the defaults here.
        //star
        if (this.options.has("starfusion-mem")) {
            this.starfusionMemory = options.valueOf("starfusion-mem").toString();
        }
        if (this.options.has("template-type")) {
            this.templateType = this.options.valueOf("template-type").toString();
            if (!this.templateType.equals("WT")) {
                Log.error("Wrong template type; Runs only for WT");
            }
        }

        ReturnValue val = super.init();

        return val;
    }

    @Override
    protected ReturnValue doFinalCheck(String commaSeparatedFilePaths, String commaSeparatedParentAccessions) {
        this.inputRead1Fastq = null;
        this.inputRead2Fastq = null;

        String[] filePaths = commaSeparatedFilePaths.split(",");
        if (filePaths.length != 2) {
            Log.error("This Decider supports only cases where we have only 2 files per lane, WON'T RUN");
            return new ReturnValue(ReturnValue.INVALIDPARAMETERS);
        }

        String[] fqFilesArray = commaSeparatedFilePaths.split(",");
        for (String file : fqFilesArray) {
            int mate = idMate(file);
            switch (mate) {
                case 1:
                    if (this.inputRead1Fastq != null) {
                        Log.error("More than one file found for read 1: " + inputRead1Fastq + ", " + file);
                        return new ReturnValue(ExitStatus.INVALIDFILE);
                    }
                    this.inputRead1Fastq = file;
                    break;
                case 2:
                    if (this.inputRead2Fastq != null) {
                        Log.error("More than one file found for read 2: " + inputRead2Fastq + ", " + file);
                        return new ReturnValue(ExitStatus.INVALIDFILE);
                    }
                    this.inputRead2Fastq = file;
                    break;
                default:
                    Log.error("Cannot identify " + file + " end (read 1 or 2)");
                    return new ReturnValue(ExitStatus.INVALIDFILE);
            }
        }

        if (inputRead1Fastq == null || inputRead2Fastq == null) {
            Log.error("The Decider was not able to find both R1 and R2 fastq files for paired sequencing alignment, WON'T RUN");
            return new ReturnValue(ReturnValue.INVALIDPARAMETERS);
        }

        readGroupDataForWorkflowRun = new ReadGroupData(files.get(inputRead1Fastq), files.get(inputRead2Fastq));

        return super.doFinalCheck(commaSeparatedFilePaths, commaSeparatedParentAccessions);
    }

    @Override
    protected boolean checkFileDetails(ReturnValue returnValue, FileMetadata fm) {
        Log.debug("CHECK FILE DETAILS:" + fm);
        if (allowedTemplateTypes != null) {
            String currentTemplateType = returnValue.getAttribute(FindAllTheFiles.Header.SAMPLE_TAG_PREFIX.getTitle() + "geo_library_source_template_type");
            // Filter the data of a different template type if filter is specified
            if (!this.templateType.equalsIgnoreCase(currentTtype)) {
                Log.warn("Excluding file with SWID = [" + returnValue.getAttribute(FindAllTheFiles.Header.FILE_SWA.getTitle())
                        + "] due to template type/geo_library_source_template_type = [" + currentTtype + "]");
                return false;}
                
        if (!allowedTemplateTypes.contains(currentTemplateType)) {
                    return false;
                }
            }
            this.externalName = returnValue.getAttribute(FindAllTheFiles.Header.SAMPLE_NAME.getTitle());

            return super.checkFileDetails(returnValue, fm);
        }

        @Override
        protected Map<String, String> modifyIniFile
        (String commaSeparatedFilePaths, String commaSeparatedParentAccessions
        
            ) {
        Log.debug("INI FILE:" + commaSeparatedFilePaths);

            Map<String, String> iniFileMap = super.modifyIniFile(commaSeparatedFilePaths, commaSeparatedParentAccessions);
            iniFileMap.put("input_read1_fastq", inputRead1Fastq);
            iniFileMap.put("input_read2_fastq", inputRead2Fastq);
            iniFileMap.put("starfusion_mem", this.starfusionMemory);
           iniFileMap.put("external_name", this.externalName);

            if (!this.queue.isEmpty()) {
                iniFileMap.put("queue", this.queue);
            }

            return iniFileMap;
        }
    

    public static void main(String args[]) {

        List<String> params = new ArrayList<String>();
        params.add("--plugin");
        params.add(STARfusionDecider.class.getCanonicalName());
        params.add("--");
        params.addAll(Arrays.asList(args));
        System.out.println("Parameters: " + Arrays.deepToString(params.toArray()));
        net.sourceforge.seqware.pipeline.runner.PluginRunner.main(params.toArray(new String[params.size()]));

    }

}
