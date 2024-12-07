import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RadioSearchComponent } from './radio-search.component';

describe('RadioSearchComponent', () => {
  let component: RadioSearchComponent;
  let fixture: ComponentFixture<RadioSearchComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RadioSearchComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(RadioSearchComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
