﻿namespace Qram{
    
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;


//BUCKET-BRIGADE
///////////////////////////////////////////////////////////////////////////
// PUBLIC API
///////////////////////////////////////////////////////////////////////////
    
     
   /// # Summary
   /// Type representing a generic BBQRAM type.
   /// # Input
   /// ## Lookup
   /// The named operation that will look up data from the BBQRAM. 
   /// ## AddressSize
   /// The size (number of bits) needed to represent an address for the QRAM.
   /// ## DataSize
   /// The size (number of bits) needed to represent a data value for the QRAM.
  newtype BBQRAM = (
   AddressSize : Int, 
   DataSize : Int
   );

  /// # Summary
  /// Creates an instance of an bucket-brigade QRAM given the data it needs to store.
  /// # Input
  /// ## dataValues
  /// An array of tuples of the form (address, value) where the address is the address 
  /// of the auxillary register to which the memory register is connected via CNOT gate and 
  /// value is the data stored (either 0 or 1) in the memory register. 
  /// # Output
  /// BBRQRAM type
  function BBQRAMOracle(dataValues : ((Int, Bool)[])) : BBQRAM{   
    let largestAddress = Microsoft.Quantum.Math.Max(
    Microsoft.Quantum.Arrays.Mapped(Fst<Int, Bool>, dataValues));
        let addressx = Mapped(Fst<Int, Bool>, dataValues);
        
        //let bbqrams =Mapped(BB, addressx);

        return Default<BBQRAM>()
           // w/ LookupBB <- bbqrams
            w/ AddressSize <- BitSizeI(largestAddress)
            w/ DataSize <- 1;
  }

  /// # Summary
  /// Returns an operation that represents a BBQRAM with one data value.
  /// # Input
  /// ## address
  /// The address of auxillary register where the data is non-zero.
  /// ## value
  /// The value (as a Bool) representing the data at `address`
  /// # Output
  ///  An operation that can be used to look up data `value` at `address`

  // function BB(address: Int)
  //  : ((LittleEndian, Qubit[], Qubit[], Qubit) => Unit is Adj + Ctl) {
  //      return ApplyBBQRAM( _, _, _,_);
  //  }
    
  /// # Summary
  /// 
  /// # Input
  /// ## address
  /// 
  /// ## value
  /// 
  /// ## addressRegister
  /// State of the address qubits stored in little endian format.
  /// ## auxillaryRegister
  /// State of the auxilary qubits.
  /// ## memoryRegister
  /// State of a particular memory register qubit.
  /// ## target
  /// State of the target qubit.
 operation ApplyBBQRAM(addressRegister : LittleEndian, auxillaryRegister:Qubit[], memoryRegister:Qubit[], target : Qubit) : Unit is Adj + Ctl
    {   
        within{
            ApplyAddressFanout(addressRegister, auxillaryRegister);
        } apply{Readout((auxillaryRegister), memoryRegister, target);}
                           
    }

 /// # Summary
 /// Performs the FANOUT part of the bucket-brigade.
 /// # Input
 /// ## addressRegister
 /// 
 /// ## auxillaryRegister
 /// 
 internal operation ApplyAddressFanout(addressRegister : LittleEndian, auxillaryRegister : Qubit[]) : Unit is Adj + Ctl
    { 
       let addressRegister1 = Reversed(addressRegister!);
       let n = Length(addressRegister!);
       X(auxillaryRegister[0]);
       for (i in 0..(n-1)){
            for (j in 0..2^(n-i)..((2^n)-1))
            {
               CCNOT(addressRegister1[i], auxillaryRegister[j], auxillaryRegister[j + 2^(n-i-1)]);
               CNOT(auxillaryRegister[j + 2^(n-i-1)], auxillaryRegister[j]); 
                }
            }   
       
    }
    
    /// # Summary
    /// Performs the QUERY part of the bucket-brigade
    /// # Input
    /// ## address
    /// 
    /// ## auxillaryRegister
    /// 
    /// ## memoryRegister
    /// 
    /// ## target
    /// 
    internal operation Readout(auxillaryRegister : Qubit[], memoryRegister : Qubit[], target : Qubit) : Unit
    is Adj + Ctl {
        for (i in 0..(Length(auxillaryRegister)-1)){
            CCNOT(auxillaryRegister[i], memoryRegister[i], target);
       }
    
        
    }
 
}
