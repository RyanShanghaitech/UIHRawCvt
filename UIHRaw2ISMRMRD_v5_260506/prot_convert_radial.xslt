<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="convert_parameter" select="default"/>
  <!-- TODO read from patient parameter and pass as xslt param ? -->
  <xsl:param name="patient_position">HFP</xsl:param>
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/">
    <!-- const begin -->
		<!-- Encoding Mode 2D, Multislice 2D or 3D -->
		<xsl:variable name="kDIMENSION_2D">1</xsl:variable>
		<xsl:variable name="kDIMENSION_3D">2</xsl:variable>
		<xsl:variable name="notMultiSliceMode">0</xsl:variable>

		<!-- Recon 2D (RO-PE plane) kspace interpolation 1x, 2x, 1.5x  -->
		<xsl:variable name="kINT_2x">1</xsl:variable>
		<xsl:variable name="kINT_1x">0</xsl:variable>

		<!-- Fast imaging methods: no, Fast1D, Fast2D, Fast2DT, uCS2D, 4DMRA -->
		<xsl:variable name="kPPAMethod_None">0</xsl:variable>
		<xsl:variable name="kPPAMethod_Fast1D">1</xsl:variable>
		<xsl:variable name="kPPAMethod_Fast2D">10</xsl:variable>
		<xsl:variable name="kPPAMethod_uCS">11</xsl:variable>
		<xsl:variable name="kPPAMethod_Fast2DT">20</xsl:variable>
		<xsl:variable name="kPPAMethod_4DMRA">33</xsl:variable>
    <!-- const end -->

    <!-- variable begin -->
		<!-- EncodingMode 2D or 3D -->
		<xsl:variable name="is_3D"                   	select="/UProtocol/Root/IRIP/FromSeq/KSpace/EncodingMode3D/Value" />
		<xsl:variable name="dimension" 			        select="/UProtocol/Root/Seq/KSpace/Dimension/Value" />

		<!-- EncodingSpace 1st dimension - Readout(RO) -->
		<xsl:variable name="matrix_ro_ui" 		       	select="/UProtocol/Root/Seq/KSpace/MatrixRO/Value" />
		<xsl:variable name="matrix_ro_real" 	       	select="matrix_ro_ui*2" />

		<!-- EncodingSpace 2nd dimension - PhaseEncoding(PE) -->
		<xsl:variable name="matrix_pe_ui" 		       	select="/UProtocol/Root/Seq/KSpace/MatrixPE/Value" />
		<xsl:variable name="totoal_pe_sample_rate"   	select="/UProtocol/Root/Seq/KSpace/OverSamplingPE/Value div 100 +1" />
		<xsl:variable name="matrix_pe_real" 	       	select="/UProtocol/Root/IRIP/FromSeq/KSpace/FTLengthPE/Value" />
		<xsl:variable name="partial_pe_lines" 	     	select="/UProtocol/Root/IRIP/FromSeq/KSpace/PartialPELines/Value" />
		<xsl:variable name="rope_interpolation" 	   	select="/UProtocol/Root/IRIP/FromUI/Interpolation/Value" />

		<!-- Radial related -->
		<xsl:variable name="spokes" 		       		select="/UProtocol/Root/Seq/App/SpokesPerSlice/Value" />

		<!-- EncodingSpace 3rd dimension - SlicePhaseEncoding(SPE) -->
		<xsl:variable name="matrix_spe_ui" 		       	select="/UProtocol/Root/Seq/KSpace/MatrixSPE/Value" />
		<xsl:variable name="slice_per_slab" 	       	select="/UProtocol/Root/Seq/KSpace/SlicePerSlab/Value" />
		<xsl:variable name="totoal_spe_sample_rate"  	select="/UProtocol/Root/Seq/KSpace/OverSamplingSPE/Value div 100 +1" />
		<xsl:variable name="slab_interpolation" 	   	select="/UProtocol/Root/Seq/KSpace/SlabInterpolation/Value" />
		<xsl:variable name="partial_spe_lines" 	     	select="/UProtocol/Root/IRIP/FromSeq/KSpace/PartialSPELines/Value" />
		<xsl:variable name="matrix_spe_real" 	       	select="/UProtocol/Root/IRIP/FromSeq/KSpace/FTLengthSPE/Value" />

		<!-- EncodingSpace - FieldOfView(FOV) -->
		<xsl:variable name="fov_ro_ui" 			        select="/UProtocol/Root/Seq/GLI/CommonPara/FOVro/Value" />
		<xsl:variable name="fov_pe_ui" 			        select="/UProtocol/Root/Seq/GLI/CommonPara/FOVpe/Value" />
		<xsl:variable name="thickness"  		        select="/UProtocol/Root/Seq/GLI/CommonPara/Thickness/Value" />

		<!-- EncodingSpace - FastImaging (No=0,Fast1D=1,Fast2D=10,uCS2D=11,Fast2DT=20,4DMRA-33) -->
		<xsl:variable name="is_ppa_on"               	select="not(/UProtocol/Root/Seq/PPA/Method/Value=0)" />
		<xsl:variable name="fast_method"             	select="/UProtocol/Root/Seq/PPA/Method/Value" />
		<xsl:variable name="ppa_factor_1D" 	         	select="/UProtocol/Root/IRIP/FromSeq/PPA/PPAFactorPE/Value" />
		<xsl:variable name="acc_factor_pe" 	         	select="/UProtocol/Root/Seq/PPA/PPAFactorPE/Value" />
		<xsl:variable name="acc_factor_spe" 	       	select="/UProtocol/Root/Seq/PPA/PPAFactorSPE/Value" />
		<xsl:variable name="acc_factor_net" 	       	select="/UProtocol/Root/Seq/PPA/CombinedAccel/Value" />

		<!-- EncodingLimits - Slice, Repetition, Phase, Contrast, Average, Segment -->
		<xsl:variable name="MultiSliceMode"          	select="/UProtocol/Root/Seq/KSpace/MultiSliceMode/Value" />
		<xsl:variable name="slice"                   	select="/UProtocol/Root/Seq/GLI/SliceGroup/ss0/NumberOfSlice/Value"/>
		<xsl:variable name="repetition"             	select="/UProtocol/Root/Seq/Basic/Repetition/Value"/>
		<xsl:variable name="contrast"                	select="/UProtocol/Root/Seq/Basic/Contrast/Value"/>
		<xsl:variable name="segment"                 	select="/UProtocol/Root/Seq/KSpace/Segments/Value"/>
		<xsl:variable name="average"                 	select="/UProtocol/Root/Seq/KSpace/Average/Value"/>

		<xsl:variable name="has_phase"               	select="/UProtocol/Root/Seq/App/CardiacPhase/Value" />
		<xsl:variable name="phase"                    	select="/UProtocol/Root/Seq/App/CardiacPhase/Value"/>	
    <!-- variable end -->

    <ismrmrdHeader xmlns="http://www.ismrm.org/ISMRMRD" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:schemaLocation="http://www.ismrm.org/ISMRMRD ismrmrd.xsd" >
		<studyInformation>
			<studyDate>
				<xsl:value-of select="/UProtocol/Root/AcqDate/Value"/>
			</studyDate>
		</studyInformation>		
		<measurementInformation>
			<measurementID>
				<xsl:value-of select="/UProtocol/Root/MeasUID/Value"/>
			</measurementID>
			<!-- TODO read from patient parameter and pass as xslt param ? -->
			<patientPosition>
				<xsl:value-of select="$patient_position"/>
			</patientPosition>
			<protocolName>
				<xsl:value-of select="/UProtocol/Header/ProtName"/>
			</protocolName>
		</measurementInformation>
		
		<acquisitionSystemInformation>
			<systemVendor>UIH</systemVendor>
			<systemModel>N.A</systemModel>
			<systemFieldStrength_T>
				<xsl:value-of select="/UProtocol/Root/SysInfo/TX/NucleusInfo/ss0/Frequency/Value div (42.58 * 1000000)"/>
			</systemFieldStrength_T>
			<receiverChannels>
				<!-- the xslt 2.0 whichi is not support by msxml6 -->
				<!--<xsl:value-of select="sum(/UProtocol/Root/CoilSelection/Para_Array[@ParaTag='SelectedElementGroupInfo']/*/Para_String[@ParaTag='RxChannelID']/Value/(string-length(normalize-space()-string-length(translate(normalize-space(),';','')))" />-->
				<!-- the xslt 1.0 for-each trick whichi is support by msxml6 -->
				<xsl:variable name="all_rxchannelids">
					<xsl:for-each select="UProtocol/Root/CoilSelection/SelectedElementGroupInfo/*/RxChannelID/Value">
						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:value-of select="string-length(normalize-space($all_rxchannelids))-string-length(translate($all_rxchannelids,';',''))"/>
			</receiverChannels>
		</acquisitionSystemInformation>
		
		<experimentalConditions>
			<H1resonanceFrequency_Hz>
				<xsl:value-of select="/UProtocol/Root/SysInfo/TX/NucleusInfo/ss0/Frequency/Value"/>
			</H1resonanceFrequency_Hz>
		</experimentalConditions>
		
        <encoding>
			<encodedSpace>
				<matrixSize>
					<x>
						<xsl:value-of select="$matrix_ro_ui"/>
					</x>
					<y>
						<xsl:value-of select="$matrix_ro_ui"/>
					</y>
					<z>
						<xsl:choose>
							<xsl:when test="$dimension = $kDIMENSION_3D">
							  <xsl:value-of select="ceiling($slice_per_slab * $totoal_spe_sample_rate)"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</z>
				</matrixSize>
				
				<fieldOfView_mm>
					<x>
						<xsl:value-of select="$fov_ro_ui"/>
					</x>
					<y>
						<xsl:value-of select="$fov_ro_ui"/>
					</y>
					<z>
						<xsl:choose>
							<xsl:when test="$dimension = $kDIMENSION_3D ">
								<xsl:value-of select=" $thickness * $totoal_spe_sample_rate * $slice_per_slab"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select=" $thickness "/>
							</xsl:otherwise>
						</xsl:choose>
					</z>
				</fieldOfView_mm>
				
			</encodedSpace>
			
			<reconSpace>
				<matrixSize>
					<xsl:choose>
						<xsl:when test="$rope_interpolation = $kINT_1x">
							<x>
								<xsl:value-of select="$matrix_ro_ui"/>
							</x>
						</xsl:when>
						<xsl:otherwise>
							<x>
								<xsl:value-of select="$matrix_ro_ui * 2"/>
							</x>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$rope_interpolation = $kINT_1x">
							<y>
								<xsl:value-of select="$matrix_pe_ui"/>
							</y>
						</xsl:when>
						<xsl:otherwise>
							<y>
								<xsl:value-of select="$matrix_pe_ui * 2"/>
							</y>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$dimension = $kDIMENSION_3D">
							<z>
								<xsl:value-of select="$matrix_spe_ui"/>
							</z>
						</xsl:when>
						<xsl:otherwise>
							<z>1</z>
						</xsl:otherwise>
					</xsl:choose>
				</matrixSize>
			  
				<fieldOfView_mm>
					<x>
						<xsl:value-of select="$fov_ro_ui"/>
					</x>
					<y>
						<xsl:value-of select="$fov_pe_ui"/>
					</y>
					<z>
						<xsl:choose>
							<xsl:when test="$dimension=$kDIMENSION_3D">
								<xsl:value-of select=" $thickness * $slice_per_slab * $totoal_spe_sample_rate "/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select=" $thickness"/>
							</xsl:otherwise>
						</xsl:choose>
					</z>
				</fieldOfView_mm>
			</reconSpace>

			<encodingLimits>
				<kspace_encoding_step_1>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$spokes - 1"/>
					</maximum>
					<center>0</center>
				</kspace_encoding_step_1>

				<kspace_encoding_step_2>
					<xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
							<minimum>
								<xsl:value-of select="floor( ($matrix_spe_real - floor($slice_per_slab * $totoal_spe_sample_rate)) div 2)"/>
							</minimum>
						</xsl:when>
						<xsl:otherwise>
							<minimum>0</minimum>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
							<maximum>
								<xsl:value-of select="$partial_spe_lines - 1"/>
							</maximum>
						</xsl:when>
						<xsl:otherwise>
							<maximum>0</maximum>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
							<center>
								<xsl:value-of select="floor($matrix_spe_real div 2)"/>
							</center>
						</xsl:when>
						<xsl:otherwise>
							<center>0</center>
						</xsl:otherwise>
					</xsl:choose>
				</kspace_encoding_step_2>

				<!-- Todo: multi slice 2d -->
				<!-- Todo: SMS (Simultaneous MultiSlice) -->
				<slice>
					<minimum>0</minimum>
					<xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
							<maximum>0</maximum>
						</xsl:when>
						<xsl:otherwise>
							<maximum>
								<xsl:value-of select="$slice - 1"/>
							</maximum>
						</xsl:otherwise>
					</xsl:choose>
					<center>0</center>
				</slice>

				<repetition>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$repetition - 1"/>
					</maximum>
					<center>0</center>
				</repetition>

				<segment>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$segment - 1"/>
					</maximum>
					<center>0</center>
				</segment>

				<contrast>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$contrast - 1"/>
					</maximum>
					<center>0</center>
				</contrast>

				<xsl:choose>
					<xsl:when test="$has_phase">
						<phase>
							<minimum>0</minimum>
							<maximum>
								<xsl:value-of select="$phase - 1"/>
							</maximum>
							<center>0</center>
						</phase>
					</xsl:when>
					<xsl:otherwise>
						<phase>
							<minimum>0</minimum>
							<maximum>0</maximum>
							<center>0</center>
						</phase>
					</xsl:otherwise>
				</xsl:choose>

				<!-- done by uih or gadgetron?-->
				<average>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$average - 1"/>
					</maximum>
					<center>0</center>
				</average>
			</encodingLimits>
			<!-- Here fill ttrajectory to radial-->
			<trajectory>radial</trajectory>
			<trajectoryDescription>
				<identifier>UR</identifier>
				<comment>UR:UnRampSampling</comment>
			</trajectoryDescription>
			
			<parallelImaging>
				<accelerationFactor>
					<xsl:choose>
						<xsl:when test="$is_ppa_on">
							<kspace_encoding_step_1>
								<xsl:choose>
									<xsl:when test="$fast_method = $kPPAMethod_uCS">
										<xsl:value-of select="$acc_factor_net"></xsl:value-of>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$acc_factor_pe"></xsl:value-of>
									</xsl:otherwise>
								</xsl:choose>
							</kspace_encoding_step_1>
						</xsl:when>
						<xsl:otherwise>
							<kspace_encoding_step_1>1</kspace_encoding_step_1>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:choose>
						<xsl:when test="$is_ppa_on">
							<kspace_encoding_step_2>
								<xsl:choose>
									<xsl:when test="$fast_method = $kPPAMethod_uCS">
										<xsl:value-of select="$acc_factor_net"></xsl:value-of>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$acc_factor_spe"></xsl:value-of>
									</xsl:otherwise>
								</xsl:choose>
							</kspace_encoding_step_2>
						</xsl:when>
						<xsl:otherwise>
							<kspace_encoding_step_2>1</kspace_encoding_step_2>
						</xsl:otherwise>
					</xsl:choose>
				</accelerationFactor>

				<!--
					<xs:enumeration value="embedded"/> 		classic grappa
					<xs:enumeration value="interleaved"/>  	tgrappa
					<xs:enumeration value="separate"/>		acq ref data need before subsample slice kspace data
					<xs:enumeration value="other"/>			acq ref data need before subsample slice kspace data?   
				-->
				<xsl:choose>
					<xsl:when test="$fast_method = $kPPAMethod_Fast2DT">
						<calibrationMode>interleaved</calibrationMode>
					</xsl:when>
					<xsl:otherwise>
						<calibrationMode>embedded</calibrationMode>
					</xsl:otherwise>
				</xsl:choose>

				<!-- UIH real-time cine uses repetition as the interleaved-time dimension -->
				<interleavingDimension>repetition</interleavingDimension>

			</parallelImaging>
			
        </encoding>

		<sequenceParameters>
			<TR>
			    <xsl:value-of select="//TR/Value div 1000.0"/>
			</TR>
			<!-- Multi-Echo--> 
			<xsl:for-each select="//TE/Value">
				<xsl:choose>
					<xsl:when test="current() > 0">
						<TE>
							<xsl:value-of select="current() div 1000.0"/>
						</TE>
					</xsl:when>
					<xsl:otherwise>
						<TE>0</TE>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			  
			<xsl:choose>
				<xsl:when test="//TI/Value > 0">
					<TI>
						<xsl:value-of select="//TI/Value div 1000.0"/>
					</TI>
				</xsl:when>
				<xsl:otherwise>
					<TI>0</TI>
				</xsl:otherwise>
			</xsl:choose>
		</sequenceParameters>

    </ismrmrdHeader>
  </xsl:template>
</xsl:stylesheet>
