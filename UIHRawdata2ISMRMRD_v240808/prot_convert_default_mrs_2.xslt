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
	   
		<!-- EncodingSpace 3rd dimension - SlicePhaseEncoding(SPE) -->
		<xsl:variable name="matrix_spe_ui" 		       	select="/UProtocol/Root/Seq/KSpace/MatrixSPE/Value" />
		<xsl:variable name="slice_per_slab" 	       	select="/UProtocol/Root/Seq/KSpace/SlicePerSlab/Value" />
		<xsl:variable name="totoal_spe_sample_rate"  	select="/UProtocol/Root/Seq/KSpace/OverSamplingSPE/Value div 100 +1" />
		<xsl:variable name="slab_interpolation" 	   	select="/UProtocol/Root/Seq/KSpace/SlabInterpolation/Value" />
		<xsl:variable name="partial_spe_lines" 	     	select="/UProtocol/Root/IRIP/FromSeq/KSpace/PartialSPELines/Value" />
		<xsl:variable name="matrix_spe_real" 	       	select="/UProtocol/Root/IRIP/FromSeq/KSpace/FTLengthSPE/Value" />
	 
		<!-- EncodingSpace - FieldOfView(FOV) -->
		<xsl:variable name="fov_ro_ui" 			       	select="/UProtocol/Root/Seq/GLI/CommonPara/FOVro/Value" />
		<xsl:variable name="fov_pe_ui" 			       	select="/UProtocol/Root/Seq/GLI/CommonPara/FOVpe/Value" />
		<xsl:variable name="thickness"  		      	select="/UProtocol/Root/Seq/GLI/CommonPara/Thickness/Value" />

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
		<xsl:variable name="bandwidth"                 	select="/UProtocol/Root/Seq/Basic/BandWidth/Value"/>
		<xsl:variable name="contrast"                	select="/UProtocol/Root/Seq/Basic/Contrast/Value"/>
		<xsl:variable name="segment"                 	select="/UProtocol/Root/Seq/KSpace/Segments/Value"/>
		<xsl:variable name="average"                 	select="/UProtocol/Root/Seq/KSpace/Average/Value"/>

		<xsl:variable name="has_phase"               	select="/UProtocol/Root/Seq/App/CardiacPhase/Value" />
		<xsl:variable name="phase"                    	select="/UProtocol/Root/Seq/App/CardiacPhase/Value"/>
		
		<xsl:variable name="squencename"             	select="/UProtocol/Sequence"/>		
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
					    <xsl:value-of select="$matrix_pe_ui"/>
					</y>
					<z>
					    <xsl:choose>
							<xsl:when test="$dimension = $kDIMENSION_3D">
							    <xsl:value-of select="$matrix_spe_ui"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
					    </xsl:choose>
					</z>
			    </matrixSize>
			    <!-- TODO: -->
			    <fieldOfView_mm>
					<x>
					    <xsl:value-of select="$fov_ro_ui "/>
					</x>
					<y>
					    <xsl:value-of select="$fov_pe_ui "/>
					</y>
					<z>
					    <xsl:choose>
							<xsl:when test="$dimension = $kDIMENSION_3D ">
							    <xsl:value-of select=" $thickness"/>
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
					<x>
					    <xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixRO/Value"></xsl:value-of>
					</x>
					<y>
					    <xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixPE/Value"></xsl:value-of>
					</y>
					<xsl:choose>
					    <xsl:when test="$dimension = $kDIMENSION_3D">
							<z>
							    <xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixSPE/Value"></xsl:value-of>
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
							    <xsl:value-of select=" $thickness "/>
							</xsl:when>
							<xsl:otherwise>
							    <xsl:value-of select=" $thickness"/>
							</xsl:otherwise>
					    </xsl:choose>
					</z>
			    </fieldOfView_mm>
			</reconSpace>
			
			<encodingLimits>
			    <kspace_encoding_step_0>
					<minimum>0</minimum>
					<maximum>
					    <xsl:value-of select="$matrix_ro_ui -1" />
					</maximum>
					<center>
					    <xsl:value-of select="floor($matrix_ro_ui div 2)"/>
					</center>
			    </kspace_encoding_step_0>          
			  
			    <kspace_encoding_step_1>
					<minimum>0</minimum>
					<maximum>
						<xsl:value-of select="$matrix_pe_ui -1" />
					</maximum>
					<center>
						<xsl:value-of select="floor($matrix_pe_ui div 2)"/>
					</center>
			    </kspace_encoding_step_1>
			  
			    <kspace_encoding_step_2>             
					<minimum>0</minimum>

				 
				    <xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
						    <maximum>
								<xsl:value-of select="$matrix_spe_ui -1" />
						    </maximum>
						</xsl:when>
						<xsl:otherwise>
						    <maximum>0</maximum>
						</xsl:otherwise>
				    </xsl:choose>

				    <xsl:choose>
						<xsl:when test="$dimension=$kDIMENSION_3D">
						    <center>
								<xsl:value-of select="floor($matrix_spe_ui div 2)"/>
						    </center>
						</xsl:when>
						<xsl:otherwise>
						    <center>0</center>
						</xsl:otherwise>
				    </xsl:choose>
				</kspace_encoding_step_2>
			  

			    <repetition>
					<minimum>0</minimum>
					<maximum>
					    <xsl:value-of select="$repetition - 1"/>
					</maximum>
					<center>
					    <xsl:value-of select="floor($repetition div 2)"/>
					</center>
			    </repetition>

			    <segment>
					<minimum>0</minimum>
					<maximum>
					    <xsl:value-of select="$segment - 1"/>
					</maximum>
					<center>
					    <xsl:value-of select="floor($segment div 2)"/>
					</center>
			    </segment>
			  
			    <contrast>
					<minimum>0</minimum>
					<maximum>
					    <xsl:value-of select="$contrast - 1"/>
					</maximum>
					<center>
					    <xsl:value-of select="floor($contrast div 2)"/>
					</center>
			    </contrast>
			  
			    <xsl:choose>
					<xsl:when test="$has_phase">
					    <phase>
							<minimum>0</minimum>
							<maximum>
							    <xsl:value-of select="$phase - 1"/>
							</maximum>
							<center>
							    <xsl:value-of select="floor($phase div 2)"/>
							</center>
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

			    <average>
					<minimum>0</minimum>
					<maximum>
					    <xsl:value-of select="$average - 1"/>
					</maximum>
					<center>
					    <xsl:value-of select="floor($average div 2)"/>
					</center>
			    </average>
			</encodingLimits>
			<trajectory>other</trajectory>
			<trajectoryDescription>
				<identifier>UR</identifier>
				<comment>R:RampSampling; UR:UnRampSampling</comment>
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
			
			<!-- Here fill ttrajectory to cartesian-->
			<trajectory>cartesian</trajectory>
        </encoding>
      
        <sequenceParameters>
			<TR>
			    <xsl:value-of select="//TR/Value div 1000.0"/>
			</TR>
			
			<xsl:choose>
			    <xsl:when test="//TE/Value > 0">
					<TE>
					  <xsl:value-of select="//TE/Value div 1000.0"/>
					</TE>
			    </xsl:when>
			    <xsl:otherwise>
					<TE>0</TE>
			    </xsl:otherwise>
			</xsl:choose>
			
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

		<userParameters>
			
			<xsl:choose>
			  <xsl:when test="contains($squencename,'svs') or contains($squencename,'csi')">
				<!-- position info -->
				<userParameterDouble>
				  <name>PosdTra</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Position/Tra/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>PosdSag</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Position/Sag/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>PosdCor</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Position/Cor/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!-- Orientation info -->
				<userParameterDouble>
				  <name>OrientationTra</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Orientation/Tra/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>OrientationSag</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Orientation/Sag/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>OrientationCor</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/Orientation/Cor/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--inplanerotation-->
				<userParameterDouble>
				  <name>inplaneRotation</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/SliceGroup/ss0/InplaneRotAngle/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--FOV-->
				<userParameterDouble>
				  <name>RoFOV</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/FOVro/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>PeFOV</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/FOVpe/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>sliceThickness</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/Thickness/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--VOI-->
				<userParameterDouble>
				  <name>RoVOI</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/VOIro/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>PeVOI</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/VOIpe/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>ThVOI</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/GLI/CommonPara/VOIth/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--Resolution, FOR SVS resolution = 1, -->
				<userParameterDouble>
				  <name>RoRes</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixRO/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>PeRes</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixPE/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>
				<userParameterDouble>
				  <name>ThRes</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/IRIP/App/InterpolatedMatrixSPE/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--dwelltime-->
				<userParameterDouble>
				  <name>dwelltime_ns</name>
				  <value>
					<xsl:value-of select="floor(1 div $bandwidth * 10000000 + 0.5) * 100"></xsl:value-of>
				  </value>
				</userParameterDouble>
				
				<!--RFfrequency-->
				<userParameterDouble>
				  <name>RFfrequency_ppm</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/App/Spectroscopy/DeltaFrequency/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<userParameterDouble>
				  <name>Samples</name>
				  <value>
					<xsl:value-of select="//UProtocol/Root/Seq/App/Spectroscopy/Resolution/Value"></xsl:value-of>
				  </value>
				</userParameterDouble>

				<!--squencename-->
				<userParameterString>
				  <name>squencename</name>
				  <value>
					<xsl:value-of select="//UProtocol/Sequence"></xsl:value-of>
				  </value>
				</userParameterString>      
				
			  </xsl:when>  
			</xsl:choose>
		</userParameters>
      
    </ismrmrdHeader>
	</xsl:template>
</xsl:stylesheet>
