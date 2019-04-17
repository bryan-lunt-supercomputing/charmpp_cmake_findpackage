-include ../../../common.mk
CHARMC = /opt/charm-6.9.0/bin/charmc $(OPTS)

TARGET = hello

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CHARMC) -language charm++ -module CommonLBs -o $@ $^

$(TARGET).decl.h: $(TARGET).ci
	$(CHARMC) $<

$(TARGET).o: $(TARGET).C $(TARGET).decl.h
	$(CHARMC) -c $<

test:
	./charmrun +p4 ./$(TARGET) ++local +balancer RotateLB

clean:
	rm -f $(TARGET) *.decl.h *.def.h *.o charmrun
